require 'replacer'

dict = Replacer.load_yaml(File.join(File.dirname(__FILE__), 'client.en.yml'))

dict['en']['js']['user']['bio'] = Replacer.replace('About me').withStr('Forum Bio')

dict.rename('en', 'en_udacity')
dict = dict.get_dict()
