def add_headers(headers)
  if page.driver.respond_to?(:headers=)
    page.driver.headers = headers
  else
    headers.each do |name, value|
      page.driver.browser.header(name, value)
    end
  end
end