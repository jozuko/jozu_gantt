class JozuGantt::SidebarViewListener < Redmine::Hook::ViewListener
  render_on :view_layouts_base_sidebar, :partial => "jozu_gantt_sidebar"
end
