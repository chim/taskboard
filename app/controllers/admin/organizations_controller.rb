class Admin::OrganizationsController < ApplicationController
  before_filter :login_required
  before_filter :check_permissions
  #layout proc{ |controller| controller.request.path_parameters[:action] == 'show' ? nil : "admin/organizations" }

  def index
    @organizations = (@current_member.admin?) ? Organization.all : @current_member.organizations
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def new
	  @organization = Organization.new
    render :partial => 'form', :object => @organization, :locals => { :edit => false }
  end
  
  def edit 
    @organization = Organization.find(params[:id])
    render :partial => 'form', :object => @organization, :locals => { :edit => true }
  end
    
  def create
    @organization = Organization.new(params[:organization])
    if @organization.save
      render :inline => "<script>location.reload(true)</script>", :status => :created
    else
      render :partial => 'form',
      		:object => @organization,
      		:locals => { :no_refresh => true, :edit => false },
 		      :status => :internal_server_error
    end
  end

  def update
    @organization = Organization.find(params[:id])

    if @organization.update_attributes(params[:organization])
      render :inline => "
      <script>
        var organization = eval(#{@organization.to_json});
        updateName('admin-div-organization-top-name',organization.organization);
      </script>"
    else
      render :update, :status => :internal_server_error do |page|
      		page.replace_html "dummy-for-actions", 
      		:partial => 'form',
      		:object => @organization,
      		:locals => { :no_refresh => true, :edit => true }
      end
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    if @organization.destroy
      render :inline => "successfully destroyed organization", :status => :ok
    else
      render :inline => "", :status => :internal_server_error
    end
  end
  
  def add_project
    @organization = Organization.find(params[:id])
  
    if params[:id]
      @project = Project.find(params[:project])
      @organization.projects << @project
      if @organization.save
        render :update do |page|
          page.replace_html "dummy-for-actions", "<script>location.reload(false)</script>"
        end
      end
    end
  end
  
  def add_member
    @organization = Organization.find(params[:id])
    @member = Member.find(params[:member])
    @membership = OrganizationMembership.new
    @membership.member = @member
    @membership.organization = @organization
    @membership.admin = nil
    if @membership.save
      # TODO: Don't refresh the whole page, just add the user.
      render :inline => "<script>location.reload(true)</script>"
    end
  end
  
  def remove_member
    @membership = OrganizationMembership.first(:conditions => ["member_id = ? and organization_id = ?", params[:object], params[:id]])
    @member = @membership.member
    @organization = @membership.organization
    @member.teams.each { |team| team.members.delete(@member) if team.projects.each { |project| project.organization == @organization } }
    if @membership.destroy
      render :inline => "", :status => :ok
    else
      render :inline => "", :status => :internal_server_error
    end
  end
  
  def toggle_admin
    @membership = OrganizationMembership.first(:conditions => ["member_id = ? and organization_id = ?", params[:member], params[:id]])

    if @membership.admin
      @membership.admin = nil
    else
      @membership.admin = true
    end
    
    if @membership.save
      render :inline => "", :status => :ok
    else
      render :inline => "", :status => :internal_server_error
    end
  end
end
