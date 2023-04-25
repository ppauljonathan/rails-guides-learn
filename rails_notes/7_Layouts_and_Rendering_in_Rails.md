# layouts and rendering in rails

## creating responses

- `render`

  to create a full response to send back to the browser

- `redirect_to`

  to send an HTTP redirect status code to the browser

- `head`

  to create a response consisting solely of HTTP headers to send back to the browser

### rendering by default

By default, controllers in Rails automatically render views with names that correspond to valid routes. even if the action is not written for it

we can define a controller action for the route

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

for action `action_name` rails will look for a file named `action_name.html.erb`

### `render`

In most cases, the `ActionController::Base#render` method does the heavy lifting of rendering your application's content for use by a browser. There are a variety of ways to customize the behavior of `render`. You can render the default view for a Rails template, or a specific template, or a file, or inline code, or nothing at all. You can render text, JSON, or XML. You can specify the content type or HTTP status of the rendered response as well.

- rendering an actions's view (from same or different controllers)

  If you want to render the view that corresponds to a different template within the same controller, you can use render with the name of the view:

  ```ruby
  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to(@book)
    else
      render "edit"
      # also:
      # render :edit, status: :unprocessable_entity # sends status 422 on response object
      # render "products/show" # renders the show method/template of ProductsController
      #   # can also use:
      # render template: "products/show"
      # render action: :edit

    end
  end
  ```

  If the call to `update` fails, calling the `update` action in this controller will render the `edit.html.erb` template belonging to the same controller.

- `render` with `:inline`

  The render method can do without a view completely, if you're willing to use the :inline option to supply ERB as part of the method call. This is perfectly valid:

  ```ruby
  render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
  ```

  NOTE: There is seldom any good reason to use this option. Mixing ERB into your controllers defeats the MVC orientation of Rails and will make it harder for other developers to follow the logic of your project. Use a separate erb view instead.

  By default, inline rendering uses ERB. You can force it to use Builder instead with the :type option:

  ```ruby
  render inline: "xml.p {'Horrid coding practice!'}", type: :builder
  ```

- rendering text
  You can send plain text - with no markup at all - back to the browser by using the `:plain` option to `render:`

  ```ruby
  render plain: "OK"
  ```

  NOTE: Rendering pure text is most useful when you're responding to Ajax or web service requests that are expecting something other than proper HTML.

  NOTE: By default, if you use the `:plain` option, the text is rendered without using the current layout. If you want Rails to put the text into the current layout, you need to add the `layout: true` option and use the `.text.erb` extension for the layout file.

- rendering html

  You can send an HTML string back to the browser by using the `:html` option to `render:`

  ```ruby
  render html: helpers.tag.strong('Not Found')
  ```

  This is useful when you're rendering a small snippet of HTML code. However, you might want to consider moving it to a template file if the markup is complex.

  When using `html:` option, HTML entities will be escaped if the string is not composed with html_safe-aware APIs.

- rendering json

  JSON is a JavaScript data format used by many Ajax libraries. Rails has built-in support for converting objects to JSON and rendering that JSON back to the browser:

  ```ruby
  render json: @product
  ```

  You don't need to call `to_json` on the object that you want to render. If you use the `:json` option, `render` will automatically call `to_json` for you.

- rendering xml

  JSON is a JavaScript data format used by many Ajax libraries. Rails has built-in support for converting objects to JSON and rendering that JSON back to the browser:

  ```ruby
  render xml: @product
  ```

  You don't need to call `to_xml` on the object that you want to render. If you use the `:xml` option, `render` will automatically call `to_xml` for you.

- rendering vanilla js

  Rails can render vanilla JavaScript:

  ```ruby
  render js: "alert('Hello Rails');"
  ```

  This will send the supplied string to the browser with a MIME type of text/javascript.

- rendering raw body

  You can send a raw content back to the browser, without setting any content type, by using the `:body` option to `render:`

  ```ruby
  render body: "raw"
  ```

  NOTE: This option should be used only if you don't care about the content type of the response. Using `:plain` or `:html` might be more appropriate most of the time.

  NOTE: Unless overridden, your response returned from this render option will be `text/plain`, as that is the default content type of Action Dispatch response.

- rendering raw files

  Rails can render a raw file from an absolute path. This is useful for conditionally rendering static files like error pages.

  ```ruby
  render file: "#{Rails.root}/public/404.html", layout: false
  ```

  This renders the raw file (it doesn't support ERB or other handlers). By default it is rendered within the current layout.

  NOTE: Using the `:file` option in combination with users input can lead to security problems since an attacker could use this action to access security sensitive files in your file system.

  NOTE: `send_file` is often a faster and better option if a layout isn't required.

- rendering objects

  Rails can render objects responding to `:render_in`.

  ```ruby
  render MyRenderable.new
  ```

  This calls `render_in` on the provided object with the current view context.

#### options for `render`

- `:content_type`

  By default, Rails will serve the results of a rendering operation with the MIME content-type of `text/html` (or `application/json` if you use the `:json` option, or `application/xml` for the `:xml` option.). There are times when you might like to change this, and you can do so by setting the `:content_type` option:

  ```ruby
  render template: "feed", content_type: "application/rss"
  ```

- `:layout`

  You can use the `:layout` option to tell Rails to use a specific file as the layout for the current action:

  ```ruby
  render layout: "special_layout"
  ```

  You can also tell Rails to render with no layout at all:

  ```ruby
  render layout: false
  ```

- `:location`

  You can use the :location option to set the HTTP Location header:

  ```ruby
  render xml: photo, location: photo_url(photo)
  ```

- `:status`

  Rails will automatically generate a response with the correct HTTP status code (in most cases, this is 200 OK). You can use the `:status` option to change this:

  ```ruby
  render status: 500
  render status: :forbidden
  ```

  Response Class|HTTP Status Code|Symbol
  -|-|-
  Informational|100|`:continue`
  -| 101 |`:switching_protocols`
  -| 102 |`:processing`
  Success|200|`:ok`
  -| 201 |`:created`
  -| 202 |`:accepted`
  -| 203 |`:non_authoritative_information`
  -| 204 |`:no_content`
  -| 205 |`:reset_content`
  -| 206 |`:partial_content`
  -| 207 |`:multi_status`
  -| 208 |`:already_reported`
  -| 226 |`:im_used`
  Redirection|300|`:multiple_choices`
  -|301|`:moved_permanently`
  -|302|`:found`
  -|303|`:see_other`
  -|304|`:not_modified`
  -|305|`:use_proxy`
  -|307|`:temporary_redirect`
  -|308|`:permanent_redirect`
  Client Error|400|`:bad_request`
  -|401|`:unauthorized`
  -|402|`:payment_required`
  -|403|`:forbidden`
  -|404|`:not_found`
  -|405|`:method_not_allowed`
  -|406|`:not_acceptable`
  -|407|`:proxy_authentication_required`
  -|408|`:request_timeout`
  -|409|`:conflict`
  -|410|`:gone`
  -|411|`:length_required`
  -|412|`:precondition_failed`
  -|413|`:payload_too_large`
  -|414|`:uri_too_long`
  -|415|`:unsupported_media_type`
  -|416|`:range_not_satisfiable`
  -|417|`:expectation_failed`
  -|421|`:misdirected_request`
  -|422|`:unprocessable_entity`
  -|423|`:locked`
  -|424|`:failed_dependency`
  -|426|`:upgrade_required`
  -|428|`:precondition_required`
  -|429|`:too_many_requests`
  -|431|`:request_header_fields_too_large`
  -|451|`:unavailable_for_legal_reasons`
  Server Error|500|`:internal_server_error`
  -|501|`:not_implemented`
  -|502|`:bad_gateway`
  -|503|`:service_unavailable`
  -|504|`:gateway_timeout`
  -|505|`:http_version_not_supported`
  -|506|`:variant_also_negotiates`
  -|507|`:insufficient_storage`
  -|508|`:loop_detected`
  -|510|`:not_extended`
  -|511|`:network_authentication_required`

  NOTE: If you try to render content along with a non-content status code (100-199, 204, 205, or 304), it will be dropped from the response.

- `:formats`

  Rails uses the format specified in the request (or `:html` by default). You can change this passing the `:formats` option with a symbol or an array:

  ```ruby
  render formats: :xml
  render formats: [:json, :xml]
  ```

  If a template with the specified format does not exist an `ActionView::MissingTemplate` error is raised.

- `:variants`

  This tells Rails to look for template variations of the same format. You can specify a list of variants by passing the `:variants` option with a symbol or an array.

  An example of use would be this.

  ```ruby
  # called in HomeController#index
  render variants: [:mobile, :desktop]
  ```

  With this set of variants Rails will look for the following set of templates and use the first that exists.

  - `app/views/home/index.html+mobile.erb`
  - `app/views/home/index.html+desktop.erb`
  - `app/views/home/index.html.erb`

  If a template with the specified format does not exist an `ActionView::MissingTemplate` error is raised.

  NOTE: Instead of setting the variant on the render call you may also set it on the request object in your controller action.

    ```ruby
    def index
      request.variant = determine_variant
    end

    private

    def determine_variant
      variant = nil
      # some code to determine the variant(s) to use
      variant = :mobile if session[:use_mobile]

      variant
    end
    ```

#### finding layouts

to render a layout rails first looks for the class base_name in `app/views/layouts/base_name.html.erb` or `app/views/layouts/base_name.builder`, if there is no controller specific layout, rails will use `app/views/layouts/application.html.erb` or `app/views/layouts/application.builder`

if there is no `.erb` layout rails will use a '.builder` layout if it exists

- specifying layouts for controllers

  You can override the default layout conventions in your controllers by using the layout declaration. For example:

  ```ruby
  class ProductsController < ApplicationController
    layout "inventory"
    #...
  end
  ```

  With this declaration, all of the views rendered by the `ProductsController` will use `app/views/layouts/inventory.html.erb` as their layout.

  To assign a specific layout for the entire application, use a layout declaration in your `ApplicationController` class:

  ```ruby
  class ApplicationController < ActionController::Base
    layout "main"
    #...
  end
  ```

  With this declaration, all of the views in the entire application will use `app/views/layouts/main.html.erb` for their layout.

- choosing layouts at runtime

  ```ruby
  class ProductsController < ApplicationController
    layout :products_layout # can also use proc

    def show
      @product = Product.find(params[:id])
    end

    private
      def products_layout
        @current_user.special? ? "special" : "products"
      end

  end
  ```

- conditional layouts

  Layouts specified at the controller level support the :only and :except options. These options take either a method name, or an array of method names, corresponding to method names within the controller:

  ```ruby
  class ProductsController < ApplicationController
    layout "product", except: [:index, :rss]
  end
  ```

- layouts inheritance

  Layout declarations cascade downward in the hierarchy, and more specific layout declarations always override more general ones. For example:

  let us take the following inheritance chain

  ```ruby
  # app/controllers/application_controller.rb
  class ApplicationController < ActionController::Base
    layout "main"
  end

  # app/controllers/articles_controller.rb
  class ArticlesController < ApplicationController
  end

  # app/controllers/special_articles_controller.rb
  class SpecialArticlesController < ArticlesController
    layout "special"
  end

  # app/controllers/old_articles_controller
  class OldArticlesController < SpecialArticlesController
    layout false

    def show
      @article = Article.find(params[:id])
    end

    def index
      @old_articles = Article.older
      render layout: "old"
    end
    # ...
  end
  ```

  here:

  - In general, views will be rendered in the `main` layout
  - `ArticlesController#index` will use the `main` layout
  - `SpecialArticlesController#index` will use the `special` layout
  - `OldArticlesController#show` will use no layout at all
  - `OldArticlesController#index` will use the `old` layout

- templates inheritance

  Similar to the Layout Inheritance logic, if a template or partial is not found in the conventional path, the controller will look for a template or partial to render in its inheritance chain. For example:

  ```ruby
  # app/controllers/application_controller.rb
  class ApplicationController < ActionController::Base
  end

  # app/controllers/admin_controller.rb
  class AdminController < ApplicationController
  end

  # app/controllers/admin/products_controller.rb
  class Admin::ProductsController < AdminController
    def index
    end
  end
  ```

  The lookup order for an `admin/products#index` action will be:

  - `app/views/admin/products/`
  - `app/views/admin/`
  - `app/views/application/`

  This makes `app/views/application/` a great place for your shared partials, which can then be rendered in your ERB as such:

  ```html
  <%# app/views/admin/products/index.html.erb %>
  <%= render @products || "empty_list" %>

  <%# app/views/application/_empty_list.html.erb %>
  There are no items in this list <em>yet</em>.
  ```

- avoiding double renders

  supposing we have some code like this:

  ```ruby
  class ProductsController < ApplicationController
    def show
      @book = Book.find(params[:id])

      if @book.special?
        render :special_show
      end

      render action: :regular_show

      # This causes double rendering which throws a AbstractController::DoubleRenderError
      # to stop this we can render and return in the same action
      # if @book.special?
      #   render action: :special_show and return
      #     # we cannot use && return because of operator presentation
      #     # or
      #   return render :special_show
      # end
      #   # or
      
      # return render :special if @book.special?
    end
  end
  ```

### `redirect_to`

`redirect_to` instructs browser to send a new request to a different url

you could redirect from wherever you are in your code to the index of photos in your application with this call:

```ruby
redirect_to photos_url
```

You can use `redirect_back` to return the user to the page they just came from. This location is pulled from the `HTTP_REFERER` header which is not guaranteed to be set by the browser, so you must provide the `fallback_location` to use in this case.

```ruby
redirect_back(fallback_location: root_path)
```

NOTE: `redirect_to` and `redirect_back` do not halt and return immediately from method execution, but simply set HTTP responses. Statements occurring after them in a method will be executed. You can halt by an explicit `return` or some other halting mechanism, if needed.

NOTE: both these methods have a default status code of 302, we can also pass custom statuses with the `status:` option

NOTE: since `redirect_to` issues a command to the browser to request the specific page, the latenecy may cause delays in the application, if this is a concern we can use `render` with a `flash` object

### `head`

The head method can be used to send responses with only headers to the browser. The head method accepts a number or symbol representing an HTTP status code. The options argument is interpreted as a hash of header names and values. For example, you can return only an error header:

```ruby
head :bad_request
```

This would produce the following header:

```text
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Or you can use other HTTP headers to convey other information:

```ruby
head :created, location: photo_path(@photo)
```

Which would produce:

```text
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

## structuring layouts

within a layout we have 3 tools for rendering the response

### asset tags

Asset tag helpers provide methods for generating HTML that link views to feeds, JavaScript, stylesheets, images, videos, and audios. There are six asset tag helpers available in Rails

NOTE: The asset tag helpers do **not** verify the existence of the assets at the specified locations; they simply assume that you know what you're doing and generate the link.

- `auto_discovery_link_tag`

  The auto_discovery_link_tag helper builds HTML that most browsers and feed readers can use to detect the presence of RSS, Atom, or JSON feeds. It takes the type of the link (:rss, :atom, or :json), a hash of options that are passed through to url_for, and a hash of options for the tag:

  ```html
  <%= auto_discovery_link_tag(:rss, {action: "feed"}, {title: "RSS Feed"}) %>
  ```

  NOTE: the first hash uses the `url_to` method to generate the href `http://www.currenthost.com/controller/action`, we can pass a full href string to the option (`auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", {title: "Example RSS"})`) or we can add other options like `{ controller: 'controller_name', action: 'action_name' }`

  the second hash has 3 options

  - `:rel` : Specify the relation of this link, defaults to “alternate”
  - `:type` : Override the auto-generated mime type
  - `:title` : Specify the title of the link, defaults to the `:type` in uppercase

- `javascript_include_tag`

  returns a HTML script tag for each source provided

  in earlier verions of rails it returned a link to `public/javascripts/`, but in the newer versions with asset pipeline enabled, it returns a link `/assets/javascripts` the sprockets gem then serves files from these  `[app|lib|vendor]/assets/javascripts/` locations

  ```html
  <%= javascript_include_tag "main" %>

  <!-- gives -->

  <script src='/assets/main.js'></script>

  <!-- we can also pass multiple files -->

  <%= javascript_include_tag "main", "columns" %>

  <!-- To include app/assets/javascripts/main.js and app/assets/javascripts/photos/columns.js: -->

  <%= javascript_include_tag "main", "/photos/columns" %>

  <!-- To include http://example.com/main.js: -->

  <%= javascript_include_tag "http://example.com/main.js" %>
  ```

- `stylesheet_link_tag`

  returns an HTML `<link>` tag for each source provided.

  If you are using Rails with the "Asset Pipeline" enabled, this helper will generate a link to `/assets/stylesheets/`. This link is then processed by the Sprockets gem. A stylesheet file can be stored in one of three locations: `app/assets`, `lib/assets`, or `vendor/assets`.

  You can specify a full path relative to the document root, or a URL. For example, to link to a stylesheet file that is inside a directory called stylesheets inside of one of `app/assets`, `lib/assets`, or `vendor/assets,` you would do this:

  ```html
  <%= stylesheet_link_tag "main" %>

  <!-- To include app/assets/stylesheets/main.css and app/assets/stylesheets/columns.css: -->

  <%= stylesheet_link_tag "main", "columns" %>

  <!-- To include app/assets/stylesheets/main.css and app/assets/stylesheets/photos/columns.css: -->

  <%= stylesheet_link_tag "main", "photos/columns" %>

  <!-- To include http://example.com/main.css: -->

  <%= stylesheet_link_tag "http://example.com/main.css" %>
  ```

  By default, the stylesheet_link_tag creates links with `rel="stylesheet"`. You can override this default by specifying an appropriate option (`:rel`)

- `image_tag`

  builds an `<img />` tag by default files are loaded from `/assets/images`

  NOTE: we **must** specify the extension of the image

  ```html
  <%= image_tag "header.png" %>
  <img src='header.png' />

  <!-- custom url -->
  <%= image_tag "icons/delete.gif" %>

  <!-- custom options -->
  <%= image_tag "icons/delete.gif", {height: 45} %>

  <!-- alt tags are added by taking the `asset_name.split('.')[0].capitalize` -->
  <%= image_tag "home.gif" %> <!-- gives alt: Home -->
  <%= image_tag "home.gif", alt: "Home" %>

  <!-- size -->
  <%= image_tag "home.gif", size: "50x20" %>

  <!-- other html -->
  <%= image_tag "home.gif", alt: "Go Home",
                            id: "HomeImage",
                            class: "nav_bar" %>
  ```

- `video_tag`

  renders a `<video>` tag to the html

  Like an `image_tag` you can supply a path, either absolute, or relative to the `/assets/videos` directory. Additionally you can specify the `size: "#{width}x#{height}"` option just like an `image_tag`. Video tags can also have any of the HTML options specified at the end (id, class et al).

  there are other options like

  - `poster: "image_name.png"`, provides an image to put in place of the video before it starts playing.
  - `autoplay: true`, starts playing the video on page load.
  - `loop: true`, loops the video once it gets to the end.
  - `controls: true`, provides browser supplied controls for the user to interact with the video.
  - `autobuffer: true`, the video will pre load the file for the user on page load.

  we can also pass an array which will render multiple video sources in a single video tag

  ```html
  <%= video_tag ["trailer.ogg", "movie.ogg"] %>

  <video>
    <source src="/videos/trailer.ogg">
    <source src="/videos/movie.ogg">
  </video>
  ```

- `audio_tag`

  renders an `<audio>` tag

  we can supply path, addtional options such as `:id`, `:class`

  special options:

  - `autoplay:` true, starts playing the audio on page load
  - `controls:` true, provides browser supplied controls for the user to interact with the audio.
  - `autobuffer:` true, the audio will pre load the file for the user on page load

  we can also supply an array to get multiple audio sources

### `yield`

Within the context of a layout, `yield` identifies a section where content from the view should be inserted. The simplest way to use this is to have a single `yield`, into which the entire contents of the view currently being rendered is inserted:

```html
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>

<!-- You can also create a layout with multiple yielding regions: -->

<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

The main body of the view will always render into the unnamed `yield`. To render content into a named yield, you use the `content_for` method.

### `content_for`

allows you to insert content into a named `yield` block in your layout. For example, this view would work with the layout that you just saw:

```html
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>

<!-- The result of rendering this page into the supplied layout would be this HTML: -->

<html>
  <head>
  <title>A simple page</title>
  </head>
  <body>
  <p>Hello, Rails!</p>
  </body>
</html>
```

The `content_for` method is very helpful when your layout contains distinct regions such as sidebars and footers that should get their own blocks of content inserted. It's also useful for inserting tags that load page-specific JavaScript or CSS files into the header of an otherwise generic layout.

### partials

- naming partials

  To render a partial as part of a view, you use the render method within the view:

  ```html
  <%= render "menu" %>
  ```

  This will render a file named `_menu.html.erb` at that point within the view being rendered. Note the leading underscore character: partials are named with a leading underscore to distinguish them from regular views, even though they are referred to without the underscore. This holds true even when you're pulling in a partial from another folder:

  ```html
  <%= render "shared/menu" %>
  ```

  That code will pull in the partial from `app/views/shared/_menu.html.erb`.

- using partials to simplify views
  One way to use partials is to treat them as the equivalent of subroutines: as a way to move details out of a view so that you can grasp what's going on more easily. For example, you might have a view that looked like this:

  ```html
  <%= render "shared/ad_banner" %>

  <h1>Products</h1>

  <p>Here are a few of our fine products:</p>
  ...

  <%= render "shared/footer" %>
  ```

  Here, the `_ad_banner.html.erb` and `_footer.html.erb` partials could contain content that is shared by many pages in your application. You don't need to see the details of these sections when you're concentrating on a particular page.

  we can also use `yield` to render other views in a partial

  ```html
  <!-- users/index.html.erb -->

  <%= render "shared/search_filters", search: @q do |form| %>
    <p>
      Name contains: <%= form.text_field :name_contains %>
    </p>
  <% end %>

  <!-- roles/index.html.erb -->

  <%= render "shared/search_filters", search: @q do |form| %>
    <p>
      Title contains: <%= form.text_field :title_contains %>
    </p>
  <% end %>

  <!-- shared/_search_filters.html.erb -->

  <%= form_with model: search do |form| %>
    <h1>Search form:</h1>
    <fieldset>
      <%= yield form %>
    </fieldset>
    <p>
      <%= form.submit "Search" %>
    </p>
  <% end %>

  <!-- the code above works like a ruby block-yielding method, the render method with the block expects the partial to use the yield to yield the block -->
  ```

- partial layouts
  A partial can use its own layout file, just as a view can use a layout. For example, you might call a partial like this:

  ```html
  <%= render partial: "link_area", layout: "graybar" %>
  ```

  This would look for a partial named `_link_area.html.erb` and render it using the layout `_graybar.html.erb`. Note that layouts for partials follow the same leading-underscore naming as regular partials, and are placed in the same folder with the partial that they belong to (not in the master layouts folder).

  Also note that explicitly specifying `:partial` is required when passing additional options such as `:layout`.

  the `_graybar.html.erb` should have a `yield` method in it which will place the code inside `_link_area.html.erb`

- passing local variables

  uses the options `:locals`, `:local_assigns`, or `:object`

  ```html
  new.html.erb

  <h1>New zone</h1>
  <%= render partial: "form", locals: {zone: @zone} %>

  edit.html.erb

  <h1>Editing zone</h1>
  <%= render partial: "form", locals: {zone: @zone} %>

  _form.html.erb

  <%= form_with model: zone do |form| %>
    <p>
      <b>Zone name</b><br>
      <%= form.text_field :name %>
    </p>
    <p>
      <%= form.submit %>
    </p>
  <% end %>
  ```

  To pass a local variable to a partial in only specific cases use the `local_assigns` hash .

  ```html
  <!-- index.html.erb -->

  <%= render user.articles %>

  <!-- show.html.erb -->

  <%= render article, full: true %>

  <!-- _article.html.erb -->

  <h2><%= article.title %></h2>

  <% if local_assigns[:full] %>
    <%= simple_format article.body %>
  <% else %>
    <%= truncate article.body %>
  <% end %>

  <!-- full is assigned to loacal_assigns[:fulll] -->


  <%= render partial: :customer, object: @new_customer %>
  <!-- since each partial has a local variable with the name of the partial  -->
  <!-- in shorthand we can also write -->
  <%= render @new_customer %>
  ```

- rendering collections

  uses the `:collection` option

  ```html
  <!-- index.html.erb -->

  <h1>Products</h1>
  <%= render partial: "product", collection: @products %>

  <!-- _product.html.erb -->

  <p>Product Name: <%= product.name %></p>

  <!-- rails will render the partial for each object of the collection -->

  <!-- we can also shorthand this -->
  <%= render @products %>
  ```

  ```html
  <!-- index.html.erb -->
  <h1>Contacts</h1>
  <%= render [customer1, employee1, customer2, employee2] %>
  <!-- rails will use the appropriate partial to render each object -->

  <!-- customers/_customer.html.erb -->
  <p>Customer: <%= customer.name %></p>

  <!-- employees/_employee.html.erb -->
  <p>Employee: <%= employee.name %></p>
  ```

  when a collection is empty `render` will return `nil`

- local variables

  to assign a object or each object of a collection to a custom local variable in a partial we use the `:as` option

  ```html
  <%= render partial: "product", collection: @products, as: :item %>

  <!-- each member of @products will be accessible in each partial as item -->

  <!-- You can also pass in arbitrary local variables to any partial you are rendering with the locals: {} option: -->

  <%= render partial: "product", collection: @products, as: :item, locals: {title: "Products Page"} %>

  ```

  NOTE: Rails also makes a counter variable available within a partial called by the collection, named after the title of the partial followed by `_counter`. For example, when rendering a collection `@products` the partial `_product.html.erb` can access the variable `product_counter` which indexes the number of times it has been rendered within the enclosing view. Note that it also applies for when the partial name was changed by using the as: option. For example, the counter variable for the code above would be item_counter.

- spacer template

You can also specify a second partial to be rendered between instances of the main partial by using the :spacer_template option:

```html
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails will render the `_product_ruler` partial (with no data passed in to it) between each pair of `_product` partials.

- collection partial layouts
we can also render collection partials by layouts

```html
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

The layout will be rendered together with the partial for each item in the collection. The current `object` and `object_counter` variables will be available in the layout as well, the same way they are within the partial.

### nested layouts

You may find that your application requires a layout that differs slightly from your regular application layout to support one particular controller. Rather than repeating the main layout and editing it, you can accomplish this by using nested layouts (sometimes called sub-templates). Here's an example:

Suppose you have the following ApplicationController layout:

```html
<!-- app/views/layouts/application.html.erb -->

<html>
<head>
  <title><%= @page_title or "Page Title" %></title>
  <%= stylesheet_link_tag "layout" %>
  <style><%= yield :stylesheets %></style>
</head>
<body>
  <div id="top_menu">Top menu items here</div>
  <div id="menu">Menu items here</div>
  <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
</body>
</html>
```

On pages generated by NewsController, you want to hide the top menu and add a right menu:

```html
<!-- app/views/layouts/news.html.erb -->

<% content_for :stylesheets do %>
  #top_menu {display: none}
  #right_menu {float: right; background-color: yellow; color: black}
<% end %>
<% content_for :content do %>
  <div id="right_menu">Right menu items here</div>
  <%= content_for?(:news_content) ? yield(:news_content) : yield %>
<% end %>
<%= render template: "layouts/application" %>
```

That's it. The News views will use the new layout, hiding the top menu and adding a new right menu inside the "content" div.

There are several ways of getting similar results with different sub-templating schemes using this technique. Note that there is no limit in nesting levels. One can use the `ActionView::render` method via `render template: 'layouts/news'` to base a new layout on the News layout. If you are sure you will not subtemplate the News layout, you can replace the `content_for?(:news_content) ? yield(:news_content) : yield` with simply `yield`.
