defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ]
  ]

  @any %{}
  @json %{ accept: %{ json: true } }
  @html %{ accept: %{ html: true } }

  define_layers [ :static, :web_page, :services, :fall_back, :not_found ]

  # In order to forward the 'themes' resource to the
  # resource service, use the following forward rule:
  #
  # match "/themes/*path", @json do
  #   Proxy.forward conn, path, "http://resource/themes/"
  # end
  #
  # Run `docker-compose restart dispatcher` after updating
  # this file.

  ###############
  # STATIC
  ###############
  get "/assets/*path", %{ layer: :static } do
    Proxy.forward conn, path, "http://frontend/assets/"
  end

  get "/@appuniversum/*path", %{ layer: :static } do
    Proxy.forward conn, path, "http://frontend/@appuniversum/"
  end

  get "/favicon.ico", %{ layer: :static } do
    send_resp( conn, 404, "" )
  end

  #################
  # FRONTEND PAGES
  #################
  get "/*path", %{ layer: :web_page, accept: %{ html: true } } do
    Proxy.forward conn, [], "http://frontend/index.html"
  end

  ###############
  # API SERVICES
  ###############
  match "/cases/*path", @json do
    Proxy.forward conn, path, "http://resource/cases/"
  end

  match "/events/*path", @json do
    Proxy.forward conn, path, "http://resource/events/"
  end

  match "/submissions/*path", @json do
    Proxy.forward conn, path, "http://resource/submissions/"
  end

  match "/identifiers/*path", @json do
    Proxy.forward conn, path, "http://resource/identifiers/"
  end

  match "/locations/*path", @json do
    Proxy.forward conn, path, "http://resource/locations/"
  end

  match "/timeframes/*path", @json do
    Proxy.forward conn, path, "http://resource/timeframes/"
  end

  get "/permits/*path", @json do
    Proxy.forward conn, path, "http://resource/permits/"
  end

  get "/decisions/*path", @json do
    Proxy.forward conn, path, "http://resource/decisions/"
  end

  get "/concepts/*path", @json do
    Proxy.forward conn, path, "http://resource/concepts/"
  end

  get "/concept-schemes/*path", @json do
    Proxy.forward conn, path, "http://resource/concept-schemes/"
  end

  get "/administrative-units/*path", @json do
    Proxy.forward conn, path, "http://resource/administrative-units/"
  end

  get "/organizations/*path", @json do
    Proxy.forward conn, path, "http://resource/organizations/"
  end

  match "/sessions/*path", @json do
    Proxy.forward conn, path, "http://login/sessions/"
  end

  get "/users/*path", @json do
    Proxy.forward conn, path, "http://resource/users/"
  end

  get "/accounts/*path", @json do
    Proxy.forward conn, path, "http://resource/accounts/"
  end

  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
