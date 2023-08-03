class PagesController < ApplicationController
  before_action :set_names, only: [:new, :edit, :show, :update, :create]
  before_action :validate_route, only: [:new, :edit, :show]
  before_action :set_page, only: [:update]

  # GET /
  def index
    @pages = Page.all
  end

  # GET /*names
  def show
    @pages = Page.all
  end

  # GET /add
  # GET /*names/add
  def new
    @page = Page.new
    if params[:names].present?
      @page.parent_id = Page.find_by_name(@names.last).id
    end
  end

  # GET /*names/edit
  def edit
  end

  # POST /
  # POST /*names
  def create
    if params[:names].present?
      @page = Page.new(page_params.merge({parent_id: Page.find_by_name(@names.last).id}))
    else
      @page = Page.new(page_params)
    end
  
    respond_to do |format|
      url = params[:names] ? params[:names] + "/" : ""
      if @page.save
        format.html { redirect_to page_path(url + @page.name), notice: 'Page was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH /*names
  def update
    respond_to do |format|
      if @page.update(page_params)
        @names[-1] = page_params[:name]
        format.html { redirect_to page_path(@names.join("/")), notice: 'Page was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  private
    def set_page
      @page = Page.find_by_name(@names.last)
    end

    def page_params
      params[:page].permit(:parent_id, :name, :header, :description)
    end

    def set_names
      @names = params[:names] ? params[:names].split("/") : nil
    end

    def validate_route
      return unless params[:names] 
      # Проверка правильности пути достраницы
      pages = Page.where(name: @names)
      @page = pages.detect{ |page| page.name == @names.last }
      # Если не существует какой-то страницы отдать 404
      not_found if @names.size != pages.count

      pages = pages.map { |page| { page.id => page.attributes.symbolize_keys.slice(:parent_id, :name) } }
      pages = pages.reduce(Hash.new, :merge)
      
      valid_str = [@page.name]
      cur_page = @page
      while valid_str.size < pages.size do
        cur_page = pages[cur_page[:parent_id]]
        # Не нашли нужную запись страницы значит неверный путь
        not_found if cur_page.nil?

        valid_str << cur_page[:name]
      end

      # Итоговая проверка верности пути
      not_found if valid_str.reverse.join("/") != params[:names] || cur_page[:parent_id] != nil
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end
end
