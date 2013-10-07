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
    },

    subcategoriesChanged: function() {
      this.set('content', this.get('controller.subcategories_objects'));
      var x = 1;
    }.observes('controller.subcategories_objects'),

    none: function() {
        if (Discourse.SiteSettings.allow_uncategorized_topics || this.get('showUncategorized')) return 'category.none';
    }.property('showUncategorized'),

    template: function(text, templateData) {
        return text;
        if (!templateData.color) return text;

        var result = "<div class='badge-category' style='background-color: #" + templateData.color + '; color: #' +
            templateData.text_color + ";'>" + templateData.name + "</div>";

        result += " <div class='topic-count'>&times; " + templateData.topic_count + "</div>";

        var description = templateData.description_text;
        // TODO wtf how can this be null?
        if (description && description !== 'null') {

            result += '<div class="category-desc">' +
                description.substr(0,200) +
                (description.length > 200 ? '&hellip;' : '') +
                '</div>';
        }
        return result;
    }

});

Discourse.View.registerHelper('subcategoryChooser', Discourse.SubcategoryChooserView);
