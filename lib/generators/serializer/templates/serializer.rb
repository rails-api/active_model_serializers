<% module_namespacing do -%>
class <%= class_name %>Serializer < <%= parent_class_name %>
  attributes <%= attributes_names.map(&:inspect).join(", ") %>
end
<% association_names.each do |attribute| -%>
  has_one :<%= attribute %>
<% end -%>
<% attributes_transformation.each do |attribute| -%>
  def <%= attribute.underscore %>
    object.<%= attribute %>
  end
<% end -%>
<% end -%>
