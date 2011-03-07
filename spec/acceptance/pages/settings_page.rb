class SettingsPage
  def initialize(page)
    @page = page
  end
  
  def visit(user)
    @page.visit "/user/#{user.id}/edit" if user
  end
end