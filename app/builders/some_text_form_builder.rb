class SomeTextFormBuilder < ActionView::Helpers::FormBuilder
  def text_field
    '<h1> Hello World </h1>'
  end
end