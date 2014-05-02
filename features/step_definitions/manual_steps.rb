When(/^I create a manual$/) do
  @fields = {
    title: 'Example Manual Title',
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
  }

  create_manual(@fields)
end

Then(/^the manual should exist$/) do
  check_manual_exists_with(@fields)
end

Given(/^a draft manual exists$/) do
  @fields = {
    title: 'Example Manual Title',
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
  }

  create_manual(@fields)
end

When(/^I edit a manual$/) do
  @new_title = 'Edited Example Manual'
  edit_manual(@fields[:title], title: @new_title)
end

Then(/^the manual should have been updated$/) do
  check_for_manual_with_title(@new_title)
end
