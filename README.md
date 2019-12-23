This Gem is used to simplify creating an HTML page that should be sent to a user from our commonly used website template.

## Context

Our website is made up of multiple services, which should all use a common **template** to display their content.
This common template is made up mainly of three parts:
* The HTML `head` area, which includes things like our general CSS and JavaScript references and other stuff that should be used globally. 
* The **header** which is the content on top of the page
* The **footer** which is the content on the bottom of the page

The actual **content** of a page within the website is located *between* the header and the footer.

Reusing our global resources requires a sort of "inverse include". 
The actual pages shouldn't *include* the general content but should be *included* in the the general content so that the header and the footer (plus anything in the header) are used correctly.

Let's make this more visually appealing by using an example. 
We'll assume that we have two pages within the context our our website that displays simple texts: "Hello world" and "Goodbye".

These pages however should be enhanced with our general header and footer.
Both pages are delivered from two independent services, so they don't have access to a shared set of resources (like CSS, icons, etc.)

Our first **target** HTML page that is delivered to a users browser should look like this:

```html
<html>
  <head>
    <link rel="stylesheet" type="text/css" href="/where/the/css/lives.css" />
  </head>
  <body>
    <header>Welcome at BetterDoc!</header>
    <div class="content">
      Hello world!
    </div>
    <footer>Managed by BetterDoc</footer>
  </body>
</html> 
```

Our second **target** HTML page should look like this:

```html
<html>
  <head>
    <link rel="stylesheet" type="text/css" href="/where/the/css/lives.css" />
  </head>
  <body>
    <header>Welcome at BetterDoc!</header>
    <div class="content">
      Goodbye!
    </div>
    <footer>Managed by BetterDoc</footer>
  </body>
</html> 
```

We can already see that the only part that changes is the belog the `<div class="content">` element.

The two services that generate the content (let's call them `HelloWorldService` and `GoodByeService`) should not be concerned with what's in the header and footer and focus on their responsibility: Creating the content.

So the actual output of these two services should be:

```html
Hello world!"
```

and 

```html
Goodbye!
```

Now we have come to what this Gem *really* does: Combining the output from a service (e.g. `HelloWorldService`) with a *template*.

The high level flow of a service that uses this Gem is quite simply:
1. Generate the actual content
2. Use the `betterdoc-website-templating` Gem to get a **complete** HTML page (incl. header and footer) for the generated content.

A simple example from within a Rails controller using this Gem will be this:

```ruby
class HelloWorldController < ApplicationController

  def say_hello

    service_content = "Hello world!"
    html_content = resolve_template(service_content)
    html_content # "<html> ... </html>"

  end

  def resolve_template(service_content)
    template_engine = Betterdoc::Website::Templating::Engine.new
    template_engine.template_location = "http://www.example.com/test/template"
    template_engine.resolve_content(title: "The page title", content: service_content) 
  end

end
```

The `Engine` takes care of loading the content from the remote template (in our example that's from the URL `http://www.example.com/test/template`) and replacing the placeholders in that content with the new values that should be sent to the browser.

## Rails

With the context of Rails the Gem will automatically initialize a concern so that the method `render_in_website_template` is available in all controllers.

```ruby
class ExampleController < ApplicationController

  def foo
    render_in_website_template('your_template')
  end

end
```


## Configuration

### Engine

The `Engine` can be configured with a set properties that specify how the replacement will be performed.

The following properties can be set at an `Betterdoc::Website::Templating::Engine` object. 
If they are not set explicitely, most of them have a default setting that will be loaded from an environment variable.

Required means that the value **must** be set either explicitely or by having an environment variable. 
If none is provided the `resolve` method call will fail with an exception.

| Property | Default environment variable | Required | Description |
| -------- | ---------------------------- | -------- | ----------- |
| `template_location` | `TEMPLATING_TEMPLATE_LOCATION` | Yes | The location of the template that should be used during the evaluation. If this location starts with either `http` or `https` it will be considered a URL and will be loaded from the specified endpoint over the network. In all other case the location is being considered a file on the local file system. |
| `template_auth_username` | `TEMPLATING_AUTH_USERNAME` | No | The username to be used when accessing the template via network using HTTP basic auth. |
| `template_auth_password` | `TEMPLATING_AUTH_PASSWORD` | No | The password to be used when accessing the template via network using HTTP basic auth. |

## Dialects

The different dialects have additional configuration options on their own

### `MustacheDialect`

The `MustacheDialect` can either be set explicitely (see below) and will be implicitely selected if no dialect has been set explicitely **and** the template path ends with `.mustache` or `.mustache.html`.

#### Usage

Template:

```html
<body>Hello {{name}}</body>
```

Ruby code:

```ruby
engine = Betterdoc::Website::Templating::Engine.new
engine.template_location = "http://www.example.com/template"
engine.dialect = Betterdoc::Website::Templating::Dialects::Mustache.new
result = engine.resolve_content(name: "my_name")
```

Output:

```html
<body>Hello my_name</body>
```

### `SimpleDialect`

The `SimpleDialect` will be selected automatically if no dialect has been selected explicitely and the template name doesn't match the pattern for the `MustacheDialect` (see above).

#### Usage

Template:

```html
<head>
  <title>INCLUDE_TITLE_HERE</title>
</head>
<body>INCLUDE_CONTENT_HERE</body>
```

Ruby code:

```ruby
engine = Betterdoc::Website::Templating::Engine.new
engine.template_location = "http://www.example.com/template"
engine.dialect = Betterdoc::Website::Templating::Dialects::SimpleDialect.new
result = engine.resolve_content(title: "a_title", content: "a_content")
```

Output:

```html
<head>
  <title>a_title</title>
</head>
<body>a_content</body>
```

#### Required elements in the context

| Context key | Required | Default | Description |
| ----------- | -------- | ------- | ---- |
| `:content` | Yes | | The content to be placed into the template. |
| `:title` | No | `BetterDoc` | The title to be placed into the template. |


#### Environment variables

| Property | Default environment variable | Default | Type |
| -------- | ---------------------------- | ------- | ---- |
| `content_placeholder` | `TEMPLATING_CONTENT_PLACEHOLDER` | `INCLUDE_CONTENT_HERE` | The placeholder within the template that should be replaced with the content from the service. |
| `title_placeholder` | `TEMPLATING_TITLE_PLACEHOLDER` | `INCLUDE_TITLE_HERE` | The placeholder within the template that should be replaced with the title. |
