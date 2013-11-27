class HomeController < ApplicationController
  def index
  end

  def a_page_for_visitors
    render text: 'a page for visitors'
  end

  def a_page_for_users
    render text: 'a page for users'
  end
end
