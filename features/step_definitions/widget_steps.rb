require 'culerity'

When /^I wait for "(.*)" button to be enabled/ do |value|
  #$browser.button(:text, value).enabled = :true
  #b = $browser.button(:text, value).set(:disabled, false)
  $browser.wait_while { $browser.button(:text, value).enabled? }
end 

When /I type in "([^\"]*)" for "([^\"]*)" and fire event "(.*)"/ do |value, field, evt|
  $browser.text_field(:id, field).set(value)
  $browser.text_field(:id, field).fire_event(evt)  
end

Then /^I should see a "(.*)" with text "(.*)"$/ do |elem, text|
  l = eval("$browser.#{elem}(:text, /#{text}/)")
  l.should be_exist
end

Then /^I should see a text input field for "(.*)"/ do |field|
  f = find_by_label_or_id(:text_field, field)
  f.should be_exist
end

Then /^I should see a select box for "(.*)"/ do |field|
  f = find_by_label_or_id(:select_list, field)
  f.should be_exist
end

Then /^"(.*)" button should be enabled/ do |value|
  f = $browser.button(:text, value)
  
  if defined?(Spec::Rails::Matchers)
    f.should be_enabled
  else
    assert f.enabled?
  end
end 
