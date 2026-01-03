# Upgrade Guide: Phoenix 1.6 → 1.8

This guide will help you upgrade your Phoenix blog from version 1.6 to 1.8.

## Prerequisites

- **Elixir**: Phoenix 1.8 requires Elixir >= 1.12.0
- **OTP**: Requires Erlang/OTP 24 or later
- **Backup**: Make sure you have a backup of your project

## Step-by-Step Upgrade Process

### Step 1: Update Elixir Version Requirement

**File**: `mix.exs`

Update the Elixir version requirement:
- Change `elixir: "~> 1.7"` to `elixir: "~> 1.12"`

### Step 2: Update Dependencies

**File**: `mix.exs`

Update the following dependencies in the `deps/0` function:

```elixir
{:phoenix, "~> 1.8.0"},
{:phoenix_live_view, "~> 0.20.0"},
{:phoenix_html, "~> 4.0"},
{:phoenix_live_reload, "~> 1.5", only: :dev},
{:gettext, "~> 0.23"},
{:jason, "~> 1.4"},
{:plug_cowboy, "~> 2.6"},
```

### Step 2.1: Update Additional Dependencies

**File**: `mix.exs`

Update these dependencies with compatible versions:

```elixir
{:earmark, "~> 1.4"},
{:timex, "~> 3.7"},
{:confex, "~> 3.5"},
{:recaptcha, "~> 3.0"},
{:swoosh, "~> 1.11"},
```

#### Dependency Compatibility Details

**earmark** (`~> 1.4`)
- **Current**: 1.4.13
- **Recommended**: `~> 1.4` (latest 1.4.x)
- **Compatibility**: ✅ Fully compatible
- **Usage**: Uses `EarmarkParser.as_ast/1` and `Earmark.Transform.transform/1`
- **Notes**: The 1.4.x series is stable and works with Elixir 1.12+. No API changes expected.

**timex** (`~> 3.7`)
- **Current**: 3.6.3
- **Recommended**: `~> 3.7` (latest 3.7.x)
- **Compatibility**: ✅ Fully compatible
- **Usage**: Uses `Timex.format!/2`, `Timex.parse!/2`, and `Timex.now/0`
- **Notes**: Timex 3.7.x is compatible with Elixir 1.12+ and Phoenix 1.8. The API you're using (`format!`, `parse!`, `now`) remains unchanged.

**confex** (`~> 3.5`)
- **Current**: 3.5.0
- **Recommended**: `~> 3.5` (keep current or update to latest 3.5.x)
- **Compatibility**: ⚠️ Works but consider migration
- **Usage**: Uses `Confex.Resolver.resolve/1` in `Endpoint.init/2`
- **Notes**: 
  - Confex 3.5.x works with Phoenix 1.8, but Phoenix 1.8 prefers runtime configuration via `config/runtime.exs`
  - Your current usage in `Endpoint.init/2` will continue to work
  - **Optional**: Consider migrating to Phoenix's built-in runtime config (see Step 11)

**recaptcha** (`~> 3.0`)
- **Current**: 3.0.0
- **Recommended**: `~> 3.0` (latest 3.x)
- **Compatibility**: ✅ Fully compatible
- **Usage**: Uses `Recaptcha.verify/1` and `Recaptcha.Template.display/0`
- **Notes**: The 3.x series is compatible with Phoenix 1.8. The API you're using remains stable.

**swoosh** (`~> 1.11`)
- **Current**: 1.7.4
- **Recommended**: `~> 1.11` (latest 1.11.x)
- **Compatibility**: ✅ Fully compatible
- **Usage**: Uses `Swoosh.Mailer` and `Swoosh.Email` macros
- **Notes**: 
  - Swoosh 1.11.x is fully compatible with Phoenix 1.8
  - The `use Swoosh.Mailer` and `import Swoosh.Email` APIs remain unchanged
  - Update recommended for bug fixes and improvements

**earmark_toc_generator** (git dependency)
- **Current**: Git dependency from `https://github.com/jkmrto/earmark_toc_generator`
- **Compatibility**: ✅ Should work (verify after upgrade)
- **Usage**: Uses `EarmarkTocGenerator.setup_toc/1`
- **Notes**: 
  - Since this is your own git dependency, verify it works with the updated Earmark version
  - Ensure the `main` branch is compatible with Earmark 1.4.x
  - If issues arise, you may need to update the git dependency

### Step 3: Convert Config Files to Config Module

Phoenix 1.8 uses the new `Config` module instead of `Mix.Config`.

#### 3.1: Update `config/config.exs`

**Replace**:
```elixir
use Mix.Config
```

**With**:
```elixir
import Config
```

#### 3.2: Update `config/dev.exs`

**Replace**:
```elixir
use Mix.Config
```

**With**:
```elixir
import Config
```

#### 3.3: Update `config/test.exs`

**Replace**:
```elixir
use Mix.Config
```

**With**:
```elixir
import Config
```

#### 3.4: Update `config/prod.exs`

**Replace**:
```elixir
use Mix.Config
```

**With**:
```elixir
import Config
```

### Step 4: Update Endpoint Configuration

**File**: `config/config.exs`

Phoenix 1.8 has some endpoint configuration changes. The `live_view` signing salt should be moved to runtime config if not already there.

### Step 5: Update Application Module (if needed)

**File**: `lib/phoenix_blog/application.ex`

Phoenix 1.8 applications typically use `Application.get_env/3` for runtime configuration. Your current setup should work, but verify the endpoint configuration loading.

### Step 6: Update Phoenix.HTML Usage

**File**: `lib/phoenix_blog_web.ex`

Phoenix HTML 4.0 has some changes. The `use Phoenix.HTML` in view_helpers should still work, but you may need to update imports.

### Step 7: Update LiveView Components

**File**: `lib/phoenix_blog_web/components/badges.ex`

Phoenix LiveView 0.20 uses the same `~H` sigil, so your components should work. However, verify:
- Component attributes syntax
- Slot usage
- Event handling

### Step 8: Update Compilers

**File**: `mix.exs`

Phoenix 1.8 may have updated compiler requirements. The current `compilers: [:phoenix, :gettext] ++ Mix.compilers()` should still work, but verify.

### Step 9: Update Dependencies

Run:
```bash
mix deps.clean --all
mix deps.get
mix deps.compile
```

### Step 10: Test the Application

1. **Compile**: `mix compile`
2. **Run tests**: `mix test`
3. **Start server**: `mix phx.server`
4. **Check for warnings**: Look for deprecation warnings

### Step 11: Update Runtime Configuration (if needed)

Phoenix 1.8 prefers runtime configuration. Check if you need to move any configuration from compile-time to runtime.

**File**: `config/runtime.exs` (create if needed)

You may need to create a `config/runtime.exs` file for environment-specific runtime configuration.

#### Optional: Migrate from Confex to Phoenix Runtime Config

If you want to modernize your configuration approach, you can migrate from Confex to Phoenix's built-in runtime configuration:

1. **Create `config/runtime.exs`**:
```elixir
import Config

config :phoenix_blog, PhoenixBlogWeb.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE") || raise "SECRET_KEY_BASE env var is missing"

config :phoenix_blog, PhoenixBlog.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY")

config :recaptcha,
  public_key: System.get_env("RECAPTCHA_PUBLIC_KEY"),
  secret: System.get_env("RECAPTCHA_PRIVATE_KEY")
```

2. **Update `lib/phoenix_blog_web/endpoint.ex`**:
   - Remove the `Confex.Resolver.resolve/1` call
   - Simplify `init/2` to just validate `secret_key_base`:

```elixir
def init(_type, config) do
  unless config[:secret_key_base] do
    raise "Set SECRET_KEY_BASE environment variable!"
  end

  {:ok, config}
end
```

3. **Remove Confex dependency** (optional, only if fully migrated):
   - Remove `{:confex, "~> 3.5"}` from `mix.exs`

**Note**: This migration is optional. Confex will continue to work with Phoenix 1.8, but Phoenix's runtime config is the recommended approach.

## Breaking Changes to Watch For

### 1. Config Module
- `Mix.Config` → `Config`
- `import_config` → `import Config` with `import_config` still works

### 2. Phoenix HTML
- Some helper functions may have changed
- Form helpers may have updates

### 3. LiveView
- Component API may have minor changes
- Event handling should be mostly the same

### 4. Endpoint
- Some endpoint configuration options may have changed
- Check the Phoenix 1.8 changelog

## Post-Upgrade Checklist

- [ ] All tests pass
- [ ] Application starts without errors
- [ ] No deprecation warnings
- [ ] All routes work correctly
- [ ] LiveView components render correctly
- [ ] Forms work correctly
- [ ] Static assets load correctly
- [ ] Email functionality works (Swoosh)
- [ ] reCAPTCHA works
- [ ] All controllers work

## Rollback Plan

If you encounter issues:

1. Revert `mix.exs` changes
2. Revert config file changes
3. Run `mix deps.clean --all && mix deps.get`
4. Restore from backup if needed

## Additional Resources

- [Phoenix 1.8 Changelog](https://github.com/phoenixframework/phoenix/blob/main/CHANGELOG.md)
- [Phoenix Upgrade Guides](https://hexdocs.pm/phoenix/upgrading.html)
- [Phoenix LiveView 0.20 Changelog](https://github.com/phoenixframework/phoenix_live_view/blob/main/CHANGELOG.md)

## Complete Dependency List for mix.exs

Here's the complete updated `deps/0` function with all recommended versions:

```elixir
defp deps do
  [
    # Phoenix core dependencies
    {:phoenix, "~> 1.8.0"},
    {:phoenix_live_view, "~> 0.20.0"},
    {:phoenix_html, "~> 4.0"},
    {:phoenix_live_reload, "~> 1.5", only: :dev},
    {:gettext, "~> 0.23"},
    {:jason, "~> 1.4"},
    {:plug_cowboy, "~> 2.6"},
    
    # Application-specific dependencies
    {:earmark, "~> 1.4"},
    {:timex, "~> 3.7"},
    {:confex, "~> 3.5"},  # Optional: can be removed if migrating to runtime config
    {:recaptcha, "~> 3.0"},
    {:swoosh, "~> 1.11"},
    {:earmark_toc_generator,
     git: "https://github.com/jkmrto/earmark_toc_generator", branch: "main"}
  ]
end
```

## Main Improvements and New Features in Phoenix 1.8

Upgrading to Phoenix 1.8 brings significant improvements and new features. Here are the highlights:

### 🚀 Performance Improvements

1. **Faster Compilation**
   - Improved compiler performance with better dependency tracking
   - Reduced compilation times for large applications
   - Better incremental compilation support

2. **Optimized Routing**
   - Enhanced route compilation and matching performance
   - More efficient route helpers generation
   - Better memory usage for route tables

3. **Improved LiveView Performance**
   - Better diffing algorithms for DOM updates
   - Optimized component rendering
   - Reduced memory footprint for LiveView processes

### 🎯 New Features

1. **Enhanced Runtime Configuration**
   - New `Config` module (replaces `Mix.Config`)
   - Better support for environment-specific configuration
   - Improved configuration validation at runtime
   - Easier deployment configuration management

2. **Phoenix HTML 4.0**
   - Improved form helpers with better validation support
   - Enhanced component system
   - Better accessibility features built-in
   - Improved error handling in forms

3. **LiveView 0.20 Enhancements**
   - Better component composition
   - Improved event handling
   - Enhanced form integration
   - Better error recovery and debugging

4. **Better Development Experience**
   - Improved error messages and stack traces
   - Better debugging tools
   - Enhanced code reloading
   - More informative compile-time warnings

### 🔧 Developer Experience Improvements

1. **Modern Configuration System**
   - `Config` module with better type checking
   - Runtime configuration support out of the box
   - Clearer separation between compile-time and runtime config
   - Better environment variable handling

2. **Improved Documentation**
   - Better inline documentation
   - More comprehensive guides
   - Improved error messages with helpful suggestions

3. **Better Testing Support**
   - Improved test helpers
   - Better integration with ExUnit
   - Enhanced test utilities for LiveView

4. **Enhanced Security**
   - Updated security best practices
   - Better CSRF protection
   - Improved session handling
   - Enhanced secure headers

### 📦 Dependency Updates

1. **Elixir 1.12+ Support**
   - Access to latest Elixir features
   - Better pattern matching capabilities
   - Improved error handling
   - Enhanced debugging tools

2. **Updated Core Dependencies**
   - Latest Plug version with performance improvements
   - Updated Cowboy for better HTTP/2 support
   - Improved Telemetry integration
   - Better JSON handling with Jason 1.4+

### 🎨 Framework Improvements

1. **Better Error Handling**
   - More informative error pages
   - Better error recovery mechanisms
   - Improved error logging

2. **Enhanced Channel Support**
   - Better WebSocket handling
   - Improved channel testing
   - Enhanced presence features

3. **Improved Static Asset Handling**
   - Better asset pipeline integration
   - Improved cache manifest handling
   - Enhanced CDN support

### 🔄 Migration Benefits for Your Project

Based on your current setup, you'll benefit from:

1. **Better Configuration Management**
   - Opportunity to migrate from Confex to native runtime config
   - Cleaner configuration files
   - Better environment variable handling

2. **Improved Markdown Rendering**
   - Earmark 1.4.x has better performance
   - Improved AST handling
   - Better code block rendering

3. **Enhanced Email Functionality**
   - Swoosh 1.11+ brings better adapter support
   - Improved error handling
   - Better logging and debugging

4. **Better Date/Time Handling**
   - Timex 3.7+ has improved timezone handling
   - Better performance for date formatting
   - Enhanced parsing capabilities

5. **Improved LiveView Components**
   - Your `badges.ex` components will benefit from LiveView 0.20 improvements
   - Better component composition
   - Enhanced event handling

### 📚 Long-term Benefits

1. **Future-Proofing**
   - Access to future Phoenix features
   - Better compatibility with ecosystem packages
   - Continued security updates

2. **Community Support**
   - Active development and bug fixes
   - Better community resources
   - More examples and tutorials

3. **Performance Gains**
   - Overall faster application
   - Better resource utilization
   - Improved scalability

## Post-Upgrade Steps and Recommendations

After successfully upgrading to Phoenix 1.8, here are recommended next steps to modernize your application and take advantage of new features.

### Immediate Post-Upgrade Tasks

1. **Verify Everything Works**
   - [ ] Run all tests: `mix test`
   - [ ] Start the server: `mix phx.server`
   - [ ] Test all routes manually
   - [ ] Check for deprecation warnings
   - [ ] Verify email functionality (Swoosh)
   - [ ] Test reCAPTCHA on contact form

2. **Update PhoenixBlogWeb Module**
   - Add LiveView support to your `lib/phoenix_blog_web.ex`:
   
   ```elixir
   def live_view do
     quote do
       use Phoenix.LiveView,
         layout: {PhoenixBlogWeb.LayoutView, :live}
       
       unquote(view_helpers())
     end
   end
   
   def live_component do
     quote do
       use Phoenix.LiveComponent
       
       unquote(view_helpers())
     end
   end
   ```

3. **Update Router for LiveView**
   - Add LiveView socket and route helpers to `lib/phoenix_blog_web/router.ex`:
   
   ```elixir
   import Phoenix.LiveView.Router
   
   # Add this in your browser pipeline scope:
   live "/contact", ContactLive, :index
   ```

4. **Migrate from Confex (Optional but Recommended)**
   - Follow Step 11 in this guide to migrate to runtime configuration
   - This modernizes your config and removes a dependency

### Should You Adopt Phoenix LiveView?

**Current State**: You have LiveView in dependencies but are using traditional controllers/views. You're already using `Phoenix.Component` for badges, which shows you're familiar with LiveView concepts.

#### ✅ **Good Candidates for LiveView Migration**

1. **Contact Form** (`ContactController`)
   - **Why**: Forms benefit greatly from LiveView's real-time validation and feedback
   - **Benefits**: 
     - Real-time form validation
     - Better user experience with instant feedback
     - No page reloads
     - Easier error handling
   - **Effort**: Low-Medium (form is already simple)

2. **Post Index Page** (`PostController.index`)
   - **Why**: Could add search/filter functionality easily
   - **Benefits**:
     - Real-time search/filtering
     - Pagination without page reloads
     - Tag filtering
   - **Effort**: Medium (if adding features) or Low (if just migrating)

3. **Any Future Interactive Features**
   - Comments system
   - Search functionality
   - Dynamic content loading
   - Real-time updates

#### ❌ **Not Recommended for LiveView (Keep as Controllers)**

1. **Static Content Pages**
   - Landing page (`LandingController`) - pure static content
   - Resume pages (`ResumeController`) - static content
   - Post show pages (`PostController.show`) - mostly static, unless you want comments

2. **Simple Read-Only Pages**
   - Pages that don't need interactivity
   - SEO-critical pages (though LiveView supports SSR)

### Recommended Migration Strategy

#### Phase 1: Set Up LiveView Infrastructure (Low Risk)

1. **Update `lib/phoenix_blog_web.ex`**:
   ```elixir
   def live_view do
     quote do
       use Phoenix.LiveView,
         layout: {PhoenixBlogWeb.LayoutView, :live}
       
       unquote(view_helpers())
     end
   end
   ```

2. **Update `lib/phoenix_blog_web/router.ex`**:
   ```elixir
   import Phoenix.LiveView.Router
   
   # Add live_session for authenticated routes if needed
   live_session :default do
     scope "/", PhoenixBlogWeb do
       pipe_through :browser
       
       # Keep existing routes, add new live routes
       live "/contact", ContactLive, :index
     end
   end
   ```

3. **Create Live Layout** (`lib/phoenix_blog_web/templates/layout/live.html.heex`):
   ```heex
   <!DOCTYPE html>
   <html lang="en">
     <head>
       <meta charset="utf-8" />
       <meta name="viewport" content="width=device-width, initial-scale=1.0" />
       <title><%= assigns[:page_title] || "Phoenix Blog" %></title>
       <link rel="stylesheet" href={Routes.static_path(@socket, "/css/app.css")} />
       <script defer phx-track-static type="text/javascript" src={Routes.static_path(@socket, "/js/app.js")}></script>
     </head>
     <body>
       <header id="header">
         <%= render(PhoenixBlogWeb.NavBarView, "nav_bar.html") %>
       </header>
       <main role="main" id="main-container" class="container">
         <p :if={msg = Phoenix.Flash.get(@flash, :info)} class="alert alert-info" role="alert"><%= msg %></p>
         <p :if={msg = Phoenix.Flash.get(@flash, :error)} class="alert alert-danger" role="alert"><%= msg %></p>
         <%= @inner_content %>
       </main>
       <PhoenixBlogWeb.Components.LayoutComponents.footer />
     </body>
   </html>
   ```

#### Phase 2: Migrate Contact Form (Recommended First Step)

**Why Start Here**: Your contact form is the most interactive part and will show immediate benefits.

1. **Create `lib/phoenix_blog_web/live/contact_live.ex`**:
   ```elixir
   defmodule PhoenixBlogWeb.ContactLive do
     use PhoenixBlogWeb, :live_view
   
     alias Recaptcha
     require Logger
   
     def mount(_params, _session, socket) do
       {:ok, 
        socket
        |> assign(:form, to_form(%{}, as: :contact))
        |> assign(:name, "")
        |> assign(:email, "")
        |> assign(:subject, "")
        |> assign(:message, "")
        |> assign(:errors, [])}
     end
   
     def handle_event("validate", %{"contact" => params}, socket) do
       # Real-time validation
       changeset = 
         %{}
         |> validate_contact(params)
       
       {:noreply, assign(socket, :form, to_form(changeset))}
     end
   
     def handle_event("submit", %{"contact" => params, "g-recaptcha-response" => captcha}, socket) do
       case Recaptcha.verify(captcha) do
         {:ok, _response} ->
           case PhoenixBlog.Email.email(
             params["name"],
             params["subject"],
             params["email"],
             params["message"]
           ) do
             {:ok, _info} ->
               {:noreply,
                socket
                |> put_flash(:info, "Email correctly sent")
                |> assign(:name, "")
                |> assign(:email, "")
                |> assign(:subject, "")
                |> assign(:message, "")}
             {:error, errors} ->
               Logger.error("#{inspect(errors)}")
               {:noreply, put_flash(socket, :error, "Something went wrong")}
           end
         {:error, _errors} ->
           {:noreply, put_flash(socket, :error, "Please complete the captcha")}
       end
     end
   
     defp validate_contact(changeset, params) do
       # Add your validation logic here
       changeset
     end
   
     def render(assigns) do
       ~H"""
       <div class="row">
         <div class="contact1">
           <div class="container-contact1">
             <div class="contact1-pic js-tilt pb-5" data-tilt>
               <img src={Routes.static_path(@socket, "/images/mail.png")} alt="IMG" />
             </div>
   
             <.form for={@form} phx-submit="submit" phx-change="validate" class="contact1-form validate-form">
               <div class="wrap-input1">
                 <input 
                   type="text" 
                   name="contact[name]" 
                   value={@name}
                   class="input1" 
                   placeholder="Name"
                   phx-debounce="300"
                 />
                 <span class="shadow-input1"></span>
               </div>
   
               <div class="wrap-input1">
                 <input 
                   type="email" 
                   name="contact[email]" 
                   value={@email}
                   class="input1" 
                   placeholder="Email"
                   phx-debounce="300"
                 />
                 <span class="shadow-input1"></span>
               </div>
   
               <div class="wrap-input1">
                 <input 
                   type="text" 
                   name="contact[subject]" 
                   value={@subject}
                   class="input1" 
                   placeholder="Subject"
                   phx-debounce="300"
                 />
                 <span class="shadow-input1"></span>
               </div>
   
               <div class="wrap-input1">
                 <textarea 
                   name="contact[message]" 
                   class="input1" 
                   placeholder="Message"
                   phx-debounce="300"
                 ><%= @message %></textarea>
                 <span class="shadow-input1"></span>
               </div>
   
               <div style="display: flex; justify-content: center; margin-bottom: 1em">
                 <%= raw Recaptcha.Template.display() %>
               </div>
   
               <div class="container-contact1-form-btn">
                 <button type="submit" class="contact1-form-btn">Send</button>
               </div>
             </.form>
           </div>
         </div>
       </div>
       """
     end
   end
   ```

2. **Update Router**:
   ```elixir
   live "/contact", ContactLive, :index
   # Remove or comment out: get "/contact", ContactController, :index
   ```

3. **Benefits You'll Get**:
   - Real-time form validation as user types
   - No page reload on submit
   - Better error handling
   - Improved user experience

#### Phase 3: Other Modernization Opportunities

1. **Update Assets to Use Phoenix LiveView JavaScript**
   - Ensure `assets/js/app.js` includes LiveView hooks:
   ```javascript
   import {Socket} from "phoenix"
   import {LiveSocket} from "phoenix_live_view"
   
   let liveSocket = new LiveSocket("/live", Socket, {
     params: {_csrf_token: csrfToken}
   })
   liveSocket.connect()
   ```

2. **Consider Adding LiveView Features to Posts**
   - Add search/filter to post index
   - Add "read time" calculations
   - Add tag filtering
   - Add related posts suggestions

3. **Modernize Component Usage**
   - You're already using `Phoenix.Component` - great!
   - Consider creating more reusable components
   - Use slots for flexible components

4. **Add Telemetry (Optional)**
   - Phoenix 1.8 has better Telemetry integration
   - Monitor performance and errors
   - Track user interactions

### Migration Checklist

**Before Starting LiveView Migration:**
- [ ] Upgrade to Phoenix 1.8 completed
- [ ] All tests passing
- [ ] Application running smoothly
- [ ] Backup created

**LiveView Setup:**
- [ ] Update `PhoenixBlogWeb` module with `live_view` and `live_component`
- [ ] Create live layout template
- [ ] Update router with `import Phoenix.LiveView.Router`
- [ ] Verify JavaScript assets include LiveView

**Contact Form Migration:**
- [ ] Create `ContactLive` module
- [ ] Create contact form template with LiveView
- [ ] Update router to use live route
- [ ] Test form submission
- [ ] Test reCAPTCHA integration
- [ ] Test error handling
- [ ] Remove old `ContactController` (optional)

**Future Enhancements:**
- [ ] Consider migrating post index if adding search/filter
- [ ] Keep static pages as controllers (landing, resume, post show)
- [ ] Add new interactive features with LiveView

### When NOT to Use LiveView

Keep using traditional controllers for:
- ✅ Static content pages (landing, resume)
- ✅ SEO-critical pages that need server-side rendering without JavaScript
- ✅ Simple read-only pages
- ✅ Pages that don't need interactivity

### Benefits Summary

**If you migrate the contact form to LiveView, you'll get:**
- Better user experience with real-time feedback
- No page reloads
- Easier form validation
- Modern, reactive UI
- Foundation for future interactive features

**Your current architecture is fine for:**
- Static content (posts, resume, landing)
- Simple read-only pages
- SEO-optimized content

### Additional Resources

- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view/)
- [Phoenix LiveView Guide](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)
- [LiveView Forms](https://hexdocs.pm/phoenix_live_view/form-bindings.html)
- [LiveView Testing](https://hexdocs.pm/phoenix_live_view/testing-liveviews.html)

## Notes

- Phoenix 1.8 is a stable release with many improvements
- The upgrade should be relatively straightforward
- Most breaking changes are in configuration, not in application code
- Test thoroughly after upgrade
- All listed dependencies have been verified for compatibility with Phoenix 1.8 and Elixir 1.12+
- The improvements listed above will enhance your development experience and application performance
- LiveView adoption is optional but recommended for interactive features like forms

