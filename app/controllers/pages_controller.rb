class PagesController < ApplicationController
  
  def show
    if @page = Page.find(params[:id])
    else
      @page = Page.find("page-not-found")
    end
    
    @page.page_parts.each do |pp|
      instance_variable_set "@#{pp.title.gsub(' ', '_').downcase}", @page.page_part_placements.find_by_page_part_id(pp.id)
    end
    #@body = @page.page_parts.find_by_section_title("body")
  end
  
end
