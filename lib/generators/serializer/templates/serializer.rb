<% module_namespacing do -%>
class <%= class_name %>Serializer < <%= parent_class_name %>
  attributes <%= attributes_names.map(&:inspect).join(", ") %>
end
<% association_names.each do |attribute| -%>
  attribute :<%= attribute %>
<% end -%>
<% end -%>
