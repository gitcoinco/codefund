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
    options = [Pending: 1, Active: 2, Archived: 3]

    options
    |> Enum.find(fn {_key, val} -> val == status end)
    |> elem(0)
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
end
