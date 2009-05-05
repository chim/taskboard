class MembersController < ApplicationController
  before_filter :login_required, :except => [:login, :logout]
  before_filter :check_permissions, :except => [:login, :logout, :access_denied, :show_form]
    
  # GET /members
  def index
    @members = Member.find(:all)
  end

  # GET /members/1
  def show
    @member = Member.find(params[:id])
  end

  # GET /members/new
  def new
    @member = Member.new
    @team = params[:team] if params[:team]
  end

  # GET /members/1/edit
  def edit
    @member = Member.find(params[:id])
  end

  # POST /members
  def create
    @member = Member.new(params[:member])
    @roles = Role.all

    if params[:roles].nil?
      @member.roles.each {|role| @member.roles.delete(role)}
    else
      @roles.each do |role|
        if params[:roles].include?("#{role.id}")
          @member.roles << role if !@member.roles.include?(role)
        else
          @member.roles.delete(role)
        end
      end
    end
    
    if(params[:dynamic])
      if @member.save
        @project = Project.find(params[:project])
        @membership = OrganizationMembership.new
        @membership.organization = @project.organization
        @membership.member = @member
        @membership.save
        
        if(params[:picture_file])
          added = @member.add_picture(params[:picture_file])
          if( added == "ok")
            render :inline => "<script>window.parent.location.reload(true);</script>"
          else
            render :inline => "<script>window.parent.location.reload(true);</script>"
          end
        end
      else
        render :inline => "Error adding member"
      end
    else
      if @member.save
        if(params[:picture_file])
          added = @member.add_picture(params[:picture_file])
          if( added == "ok")
            render :inline => "<script>window.parent.location.reload(true);</script>"
          else
            # Add error handling and report
            render :inline => "<script>window.parent.location.reload(true);</script>"
          end
        end
        redirect_to(@member)
      else
        render :action => "new"
      end
    end
  end

  # PUT /members/1
  def update
    @member = Member.find(params[:id])
    if(params[:dynamic])
      @member.update_attributes(params[:member])
      @roles = Role.all

      if params[:roles].nil?
        @member.roles.each {|role| @member.roles.delete(role)}
      else
        @roles.each do |role|
          if params[:roles].include?("#{role.id}")
            @member.roles << role if !@member.roles.include?(role)
          else
            @member.roles.delete(role)
          end
        end
      end

      if @member.save
        if(params[:picture_file])
          added = @member.add_picture(params[:picture_file])
          if( added == "ok")
            render :inline => "<script>window.parent.location.reload(true);</script>"
          else
            # Add error handling and report
            render :inline => "<script>window.parent.location.reload(true);</script>"
          end
        end
        #redirect_to(:controller => :teams, :project => params[:project])
      else
        render :inline => "username already taken"
      end
    else
      if @member.update_attributes(params[:member])
        redirect_to(@member)
      else
        render :action => "edit"
      end
    end
  end

  # DELETE /members/1
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    if(params[:dynamic])
      render :inline => "<script>location.reload(true);</script>"
    else
      redirect_to(members_url)
    end
  end

  # Member form, used to display the partial of the member's form when adding or editing them.
  def show_form
    if(params[:member])
	    @member = Member.find(params[:member])
    else
	    @member = Member.new
    end

    @roles = Role.all
    @roles_selected = Array.new
    @roles.each { |role| @roles_selected << role.id if (@member.roles.include?(role)) }
    
    render :update do |page|
	    page.replace_html "dummy-for-actions", :partial => 'form', :locals => { :member => @member, :project => params[:project] }
    end
  end
  
  def login
    if request.post?
      session[:member] = Member.authenticate(params[:member][:username], params[:member][:password])
      if session[:member]
        redirect_to_stored
      else
        flash[:notice] = "Access Denied"
      end
    end
  end

  def logout
    session[:member] = nil
    if(request.referer)
      redirect_to(request.referer)
    else
      redirect_to(projects_url)
    end
  end

  def access_denied
  end
  
  def delete_member
    @member = Member.find(params[:id])
    @member.destroy
    @members = Member.all()
    
    render :update do |page| 
      page.replace_html "members-list", :partial => "teams/members_list", :locals => { :members => @members, :project => params[:project] }
    end
  end

  def make_sysadmin
    @member = Member.find(params[:id])
    @member.admin = true
    @member.save
    render :update do |page|
      page.replace_html "dummy-for-actions", "<script>location.reload(true)</script>"
    end
  end

  def remove_sysadmin
    @member = Member.find(params[:id])
    @member.admin = nil
    @member.save
    render :update do |page|
      page.replace_html "dummy-for-actions", "<script>location.reload(true)</script>"
    end
  end
end

