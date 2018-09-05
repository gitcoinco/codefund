defmodule CodeFundWeb.ViewHelpers do
  @doc ~S"""
  Converts a Decimal to a formatted currency amount

  ## Examples

      iex> CodeFundWeb.ViewHelpers.pretty_money(Decimal.new(1753.50), "USD")
      "$175,3.50"

  """
  def pretty_money(amount, currency \\ "USD") do
    {:ok, ret} = Money.to_string(Money.new(amount, currency), currency: currency)
    String.replace(ret, "US", "")
  end

  @doc ~S"""
  Converts an Integer to a formatted number

  ## Examples

      iex> CodeFundWeb.ViewHelpers.pretty_integer(12345678)
      "12,345,678"

  """
  def pretty_integer(num) do
    Number.Delimit.number_to_delimited(num, separator: ",", precision: 0)
  end

  @doc ~S"""
  Converts an Date to a formatted date

  ## Examples

      iex> CodeFundWeb.ViewHelpers.pretty_date(~D[2016-03-03])
      "Mar 3, 2016"

  """
  def pretty_date(date, format \\ "%b %-d, %Y")

  def pretty_date(%NaiveDateTime{} = date, format) do
    Timex.format!(date, format, :strftime)
  end

  def pretty_date(_date, _format) do
    "-"
  end

  def pretty_subtracted_money_with_total(a, b, c) do
    html = """
    <span class="money-subtract-wrapper">
      <span class="line_1">#{pretty_money(a)}</span>
      <span class="line_2">#{pretty_money(b)}</span>
      <span class="line_3 #{
      if Decimal.cmp(c, Decimal.new(0)) == :lt, do: "negative", else: "positive"
    }">#{pretty_money(c)}</span>
    </span>
    """

    {:safe, html}
  end

  def campaign_status(status) do
    options = CodeFund.Campaigns.statuses()

    options
    |> Enum.find(fn {_key, val} -> val == status end)
    |> elem(0)
  end

  def campaign_status_icon(status) do
    options = [
      "fas fa-pause-circle text-muted": 1,
      "fas fa-play-circle text-success": 2,
      "fas fa-archive": 3
    ]

    icon =
      options
      |> Enum.find(fn {_key, val} -> val == status end)
      |> elem(0)

    {:safe, "<span class=\"#{icon}\"></span>"}
  end

  def property_status_icon(status) do
    options = [
      "fas fa-pause-circle text-muted": 0,
      "fas fa-play-circle text-success": 1,
      "fas fa-thumbs-down": 2,
      "fas fa-archive": 3,
      "fas fa-ban": 4
    ]

    icon =
      options
      |> Enum.find(fn {_key, val} -> val == status end)
      |> elem(0)

    {:safe, "<span class=\"#{icon}\"></span>"}
  end

  def has_any_role?(conn, target_roles) do
    if Coherence.logged_in?(conn) do
      current_user = Coherence.current_user(conn)
      matches = Enum.filter(current_user.roles, fn role -> Enum.member?(target_roles, role) end)
      !Enum.empty?(matches)
    else
      false
    end
  end

  @spec return_key_for_value(Keyword.t(), integer | String.t()) :: String.t()
  def return_key_for_value(enum, match_value) when is_list(enum) do
    enum |> Enum.find(fn enum_tuple -> enum_tuple |> elem(1) == match_value end) |> elem(0)
  end

  def full_name(user) do
    case user do
      nil -> ""
      _ -> "#{user.first_name} #{user.last_name}"
    end
  end

  def gravatar_url(email) do
    hash =
      email
      |> String.trim()
      |> String.downcase()
      |> :erlang.md5()
      |> Base.encode16(case: :lower)

    "https://www.gravatar.com/avatar/#{hash}?s=150&d=identicon"
  end

  def ga_tag do
    ga_tracking_id = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:ga_tracking_id]

    html = """
    <script async src="https://www.googletagmanager.com/gtag/js?id=#{ga_tracking_id}"></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());

      gtag('config', '#{ga_tracking_id}');
    </script>
    """

    case ga_tracking_id do
      nil -> {:safe, ""}
      _ -> {:safe, html}
    end
  end

  def codefund_sidebar_ad_tag(conn, target) do
    template =
      case has_any_role?(conn, ["admin"]) do
        true -> "centered"
        _ -> "vertical"
      end

    property_id = Application.get_env(:code_fund, :property_id)

    html = """
    <script src="/scripts/#{property_id}/embed.js?target=#{target}&template=#{template}&theme=dark"></script>
    """

    {:safe, html}
  end

  def support_widget_tag do
    support_widget_id = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:support_widget_id]

    html = """
    <script id="grv-widget">
    /*<![CDATA[*/
    window.groove = window.groove || {}; groove.widget = function(){ groove._widgetQueue.push(Array.prototype.slice.call(arguments)); }; groove._widgetQueue = [];
    groove.widget('setWidgetId', '#{support_widget_id}');
    !function(g,r,v){var a,n,c=r.createElement("iframe");(c.frameElement||c).style.cssText="width: 0; height: 0; border: 0",c.title="",c.role="presentation",c.src="javascript:false",r.body.appendChild(c);try{a=c.contentWindow.document}catch(i){n=r.domain;var b=["javascript:document.write('<he","ad><scri","pt>document.domain=","\\"",n,"\\";</scri","pt></he","ad><bo","dy></bo","dy>')"];c.src=b.join(""),a=c.contentWindow.document}var d="https:"==r.location.protocol?"https://":"http://",s="http://groove-widget-production.s3.amazonaws.com".replace("http://",d);c.className="grv-widget-tag",a.open()._l=function(){n&&(this.domain=n);var t=this.createElement("script");t.type="text/javascript",t.charset="utf-8",t.async=!0,t.src=s+"/loader.js",this.body.appendChild(t)};var p=["<bo","dy onload=\\"document._l();\\">"];a.write(p.join("")),a.close()}(window,document)
    /*]]>*/
    </script>
    """

    case support_widget_id do
      nil -> {:safe, ""}
      _ -> {:safe, html}
    end
  end

  def privacy_policy_link do
    html = """
    <a href="https://www.iubenda.com/privacy-policy/47597768" class="iubenda-nostyle no-brand iubenda-embed iub-legal-only" title="Privacy Policy">Privacy Policy</a> <script type="text/javascript">(function (w,d) {var loader = function () {var s = d.createElement("script"), tag = d.getElementsByTagName("script")[0]; s.src="https://cdn.iubenda.com/iubenda.js"; tag.parentNode.insertBefore(s,tag);}; if(w.addEventListener){w.addEventListener("load", loader, false);}else if(w.attachEvent){w.attachEvent("onload", loader);}else{w.onload = loader;}})(window, document);</script>
    """

    {:safe, html}
  end

  def cookie_policy_link do
    html = """
    <a href="https://www.iubenda.com/privacy-policy/47597768/cookie-policy" class="iubenda-nostyle no-brand iubenda-embed " title="Cookie Policy">Cookie Policy</a> <script type="text/javascript">(function (w,d) {var loader = function () {var s = d.createElement("script"), tag = d.getElementsByTagName("script")[0]; s.src="https://cdn.iubenda.com/iubenda.js"; tag.parentNode.insertBefore(s,tag);}; if(w.addEventListener){w.addEventListener("load", loader, false);}else if(w.attachEvent){w.attachEvent("onload", loader);}else{w.onload = loader;}})(window, document);</script>
    """

    {:safe, html}
  end

  def cookie_banner do
    html = """
    <script type="text/javascript"> var _iub = _iub || []; _iub.csConfiguration = {"lang":"en","siteId":1115746,"cookiePolicyId":47597768}; </script><script type="text/javascript" src="//cdn.iubenda.com/cookie_solution/safemode/iubenda_cs.js" charset="UTF-8" async></script>
    """

    {:safe, html}
  end

  def consent_script do
    iubenda_api_key = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:iubenda_api_key]

    html = """
    <script type="text/javascript" src="https://cdn.iubenda.com/consent_solution/iubenda_cons.js"></script>
    <script type="text/javascript">
    _iub.cons.init({
        api_key: "#{iubenda_api_key}"
    });
    </script>
    """

    {:safe, html}
  end

  def show_button(path) do
    html = """
      <a href="#{path}" class="btn btn-secondary btn-sm mb-1">
        <i class="fal fa-eye"></i>
      </a>
    """

    {:safe, html}
  end

  def edit_button(path) do
    html = """
      <a href="#{path}" class="btn btn-secondary btn-sm mb-1">
        <i class="fal fa-pencil"></i>
      </a>
    """

    {:safe, html}
  end
end
