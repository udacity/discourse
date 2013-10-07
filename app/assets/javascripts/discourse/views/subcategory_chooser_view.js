/**
 This view handles rendering of a combobox that can view a category

 @class CategoryChooserView
 @extends Discourse.ComboboxView
 @namespace Discourse
 @module Discourse
 **/
Discourse.SubcategoryChooserView = Discourse.ComboboxView.extend({
    classNames: ['combobox category-combobox'],
    overrideWidths: true,
    dataAttributes: ['name'],
    valueBinding: Ember.Binding.oneWay('source'),

    init: function() {
        this._super();
        this.set('content', this.get('controller.subcategories'));
    },

    subcategoriesChanged: function() {
      this.set('content', this.get('controller.subcategories'));
      this.rerender();
    }.observes('controller.subcategories'),

    none: function() {
      return 'subcategory.none';
    }.property('showUnsubcategorized'),

    template: function(text, templateData) {
      if (templateData.name) {
        return templateData.name;
      }
      else {
        return I18n.t('subcategory.none');
      }
    }
});

Discourse.View.registerHelper('subcategoryChooser', Discourse.SubcategoryChooserView);
