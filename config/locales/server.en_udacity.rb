require 'replacer'

dict = Replacer.load_yaml(File.join(File.dirname(__FILE__), 'server.en.yml'))

dict['en']['user_profile']['no_info_me'] = Replacer.replace(
    "<div class='missing-profile'>the About Me field of your profile is currently blank, <a href='/users/%{username_lower}/preferences/about-me'>would you like to fill it out?</a></div>").withStr(
    "<div class='missing-profile'>the Forum Bio field of your profile is currently blank, <a href='/users/%{username_lower}/preferences/about-me'>would you like to fill it out?</a></div>")

dict.rename('en', 'en_udacity')
dict.get_dict()

