/*global Markdown:true BetterMarkdown:true */

var MD = window.BetterMarkdown.Markdown,
    dialect = MD.dialects.Discourse = MD.subclassDialect( MD.dialects.Gruber );

var createBBCode = function(tag, builder, hasArgs) {
  return function(text, orig_match) {
    var bbcodePattern = new RegExp("\\[" + tag + "=?([^\\[\\]]+)?\\]([\\s\\S]*?)\\[\\/" + tag + "\\]", "igm");
    var m = bbcodePattern.exec(text);
    if (m && m[0]) {
      return [m[0].length, builder(m, this)];
    }
  };
};

var createInlineBBCode = function(tag, element) {
  dialect.inline["[" + tag + "]"] = createBBCode(tag, function(m, self) {
    return element.concat(self.processInline(m[2]));
  });
};

createInlineBBCode('b', ['span', {'class': 'bbcode-b'}]);
createInlineBBCode('i', ['span', {'class': 'bbcode-i'}]);
createInlineBBCode('u', ['span', {'class': 'bbcode-u'}]);
createInlineBBCode('s', ['span', {'class': 'bbcode-s'}]);
createInlineBBCode('spoiler', ['span', {'class': 'spoiler'}]);
createInlineBBCode('li', ['li']);
createInlineBBCode('ul', ['ul']);
createInlineBBCode('ol', ['ol']);

dialect.inline["[img]"] = createBBCode('img', function(m) {
  return ['img', {href: m[2]}];
});

dialect.inline["[email]"] = createBBCode('email', function(m) {
  return ['a', {href: "mailto:" + m[2], 'data-bbcode': true}, m[2]];
});

dialect.inline["[url]"] = createBBCode('url', function(m) {
  return ['a', {href: m[2], 'data-bbcode': true}, m[2]];
});

dialect.inline["[url="] = createBBCode('url', function(m, self) {
  return ['a', {href: m[1], 'data-bbcode': true}].concat(self.processInline(m[2]));
});

dialect.inline["[email="] = createBBCode('email', function(m, self) {
  return ['a', {href: "mailto:" + m[1], 'data-bbcode': true}].concat(self.processInline(m[2]));
});

dialect.inline["[size="] = createBBCode('size', function(m, self) {
  return ['span', {'class': "bbcode-size-" + m[1]}].concat(self.processInline(m[2]));
});

dialect.inline["[color="] = function(text, orig_match) {
  var bbcodePattern = new RegExp("\\[color=?([^\\[\\]]+)?\\]([\\s\\S]*?)\\[\\/color\\]", "igm"),
      m = bbcodePattern.exec(text);

  if (m && m[0]) {
    if (!/^(\#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?)|(aqua|black|blue|fuchsia|gray|green|lime|maroon|navy|olive|purple|red|silver|teal|white|yellow)$/.test(m[1])) {
      return [m[0].length].concat(this.processInline(m[2]));
    }
    return [m[0].length, ['span', {style: "color: " + m[1]}].concat(this.processInline(m[2]))];
  }
};

dialect.inline["[code]"] = function(text, orig_match) {
  var bbcodePattern = new RegExp("\\[code\\]([\\s\\S]*?)\\[\\/code\\]", "igm"),
      m = bbcodePattern.exec(text);

  if (m) {
    var contents = m[1].trim().split("\n");

    var html = ['pre', "\n"];
    contents.forEach(function (n) {
      html.push(n.trim());
      html.push(["br"]);
      html.push("\n");
    });

    return [m[0].length, html];
  }
};

dialect.inline["[quote="] = function(text, orig_match) {
  var opts = dialect.options;

  var bbcodePattern = new RegExp("\\[quote=?([^\\[\\]]+)?\\]([\\s\\S]*?)\\[\\/quote\\]", "igm");

  var m = bbcodePattern.exec(text);
  if (!m) { return; }

  var paramsString = m[1].replace(/\"/g, ''),
      params = {'class': 'quote'},
      paramsSplit = paramsString.split(/\, */),
      username = paramsSplit[0];

  paramsSplit.forEach(function(p,i) {
    if (i > 0) {
      var assignment = p.split(':');
      if (assignment[0] && assignment[1]) {
        params['data-' + assignment[0]] = assignment[1].trim();
      }
    }
  });

  var avatar = opts.lookupAvatar ? opts.lookupAvatar(username) : null,
      quote = ['aside', params,
                  ['div', {'class': 'title'},
                    ['div', {'class': 'quote-controls'}],
                    avatar ? avatar + "\n" : "",
                    I18n.t('user.said',{username: username})
                  ],
                  ['blockquote'].concat(this.processInline(m[2]))
               ];


  return [m[0].length, quote, ['br']];
};

dialect.block['gfmcode'] = function(block, next) {
  var m = /^`{3}([^\n]+)?\n?(.*)?/gm.exec(block);
  if (m) {
    var ret = [''];
    if (m[2]) { next.unshift(MD.mk_block(m[2])); }

    while (next.length > 0) {
      var b = next.shift(),
          n = b.match(/([^`]*)```([^`]*)/m);

      if (n) {
        if (n[2]) {
          next.unshift(MD.mk_block(n[2]));
        }
        ret.push(n[1].trim());
        break;
      } else {
        ret.push(b);
      }
    }
    ret.push('');

    return [ ['p', ['pre', ['code', {'class': m[1] || 'lang-auto'}, ret.join("\n") ]]]];
  }
};

dialect.block['autolink'] = function(block, next) {
  var pattern = /(^|\s)((?:https?:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.])(?:[^\s()<>]+|\([^\s()<>]+\))+(?:\([^\s()<>]+\)|[^`!()\[\]{};:'".,<>?«»“”‘’\s]))/gm,
      result,
      remaining = block,
      m;

  var pushIt = function(p) { result.push(p) };

  while (m = pattern.exec(remaining)) {
    result = result || ['p'];

    var url = m[2],
        urlIndex = remaining.indexOf(url),
        before = remaining.slice(0, urlIndex);

    pattern.lastIndex = 0;

    remaining = remaining.slice(urlIndex + url.length);

    if (before) {
      this.processInline(before).forEach(pushIt);
    }

    var displayUrl = url;
    if (url.match(/^www/)) { url = "http://" + url; }
    result.push(['a', {href: url}, displayUrl]);

    if (remaining && remaining.match(/\n/)) {
      console.log(remaining);
      next.unshift(MD.mk_block(remaining));
    }
  }

  if (result) {
    if (remaining.length) {
      this.processInline(remaining).forEach(pushIt);
    }

    return [result];
  }

};

MD.buildBlockOrder ( dialect.block );
MD.buildInlinePatterns( dialect.inline );

/**
  Contains methods to help us with markdown formatting.

  @class Markdown
  @namespace Discourse
  @module Discourse
**/
Discourse.Markdown = {

  /**
    Convert a raw string to a cooked markdown string.

    @method cook
    @param {String} raw the raw string we want to apply markdown to
    @param {Object} opts the options for the rendering
    @return {String} the cooked markdown string
  **/
  cook: function(raw, opts) {
    if (!opts) opts = {};

    // Make sure we've got a string
    if (!raw) return "";
    if (raw.length === 0) return "";

    return this.markdownConverter(opts).makeHtml(raw);
  },

  /**
    Creates a new pagedown markdown editor, supplying i18n translations.

    @method createEditor
    @param {Object} converterOptions custom options for our markdown converter
    @return {Markdown.Editor} the editor instance
  **/
  createEditor: function(converterOptions) {

    if (!converterOptions) converterOptions = {};

    // By default we always sanitize content in the editor
    converterOptions.sanitize = true;

    var markdownConverter = Discourse.Markdown.markdownConverter(converterOptions);

    var editorOptions = {
      strings: {
        bold: I18n.t("composer.bold_title") + " <strong> Ctrl+B",
        boldexample: I18n.t("composer.bold_text"),

        italic: I18n.t("composer.italic_title") + " <em> Ctrl+I",
        italicexample: I18n.t("composer.italic_text"),

        link: I18n.t("composer.link_title") + " <a> Ctrl+L",
        linkdescription: I18n.t("composer.link_description"),
        linkdialog: "<p><b>" + I18n.t("composer.link_dialog_title") + "</b></p><p>http://example.com/ \"" +
            I18n.t("composer.link_optional_text") + "\"</p>",

        quote: I18n.t("composer.quote_title") + " <blockquote> Ctrl+Q",
        quoteexample: I18n.t("composer.quote_text"),

        code: I18n.t("composer.code_title") + " <pre><code> Ctrl+K",
        codeexample: I18n.t("composer.code_text"),

        image: I18n.t("composer.upload_title") + " - Ctrl+G",
        imagedescription: I18n.t("composer.upload_description"),

        olist: I18n.t("composer.olist_title") + " <ol> Ctrl+O",
        ulist: I18n.t("composer.ulist_title") + " <ul> Ctrl+U",
        litem: I18n.t("composer.list_item"),

        heading: I18n.t("composer.heading_title") + " <h1>/<h2> Ctrl+H",
        headingexample: I18n.t("composer.heading_text"),

        hr: I18n.t("composer.hr_title") + " <hr> Ctrl+R",

        undo: I18n.t("composer.undo_title") + " - Ctrl+Z",
        redo: I18n.t("composer.redo_title") + " - Ctrl+Y",
        redomac: I18n.t("composer.redo_title") + " - Ctrl+Shift+Z",

        help: I18n.t("composer.help")
      }
    };

    return new Markdown.Editor(markdownConverter, undefined, editorOptions);
  },

  /**
    Creates a Markdown.Converter that we we can use for formatting

    @method markdownConverter
    @param {Object} opts the converting options
  **/
  markdownConverter: function(opts) {
    if (!opts) opts = {};
    dialect.options = opts;

    return {
      makeHtml: function(text) {

        // Plugins
        Discourse.Markdown.textResult = null;
        Discourse.Markdown.trigger('beforeCook', { detail: text, opts: opts });
        text = Discourse.Markdown.textResult || text;

        // Linebreaks
        var linebreaks = opts.traditional_markdown_linebreaks || Discourse.SiteSettings.traditional_markdown_linebreaks;
        if (!linebreaks) {
          text = text.replace(/(^[\w<][^\n]*\n+)/gim, function(t) {
            if (t.match(/\n{2}/gim)) return t;
            return t.replace("\n", "  \n");
          });
        }

        // perform op
        var isOnOneLine = function(link, parent) {
          if (!parent) { return false; }

          var siblings = parent.slice(1);
          if ((!siblings) || (siblings.length < 1)) { return false; }

          var idx = siblings.indexOf(link);
          if (idx === -1) { return false; }

          if (idx > 0) {
            var prev = siblings[idx-1];
            if (prev[0] !== 'br') { return false; }
          }

          if (idx < (siblings.length-1)) {
            var next = siblings[idx+1];
            if (next[0] !== 'br') { return false; }
          }

          return true;
        };

        var parseLink = function(node, path) {
          var parent = path[path.length - 1];

          // if (node[1].href) {
          //   node[1].href = node[1].href.replace(/\_\_/g, "%5F%5F");
          // }

          // onebox:

          // We don't onebox bbcode
          if (node[1]['data-bbcode']) {
            delete node[1]['data-bbcode'];
            return;
          }

          // Don't onebox links within a list
          for (var i=0; i<path.length; i++) {
            if (path[i][0] === 'li') { return; }
          }

          if (isOnOneLine(node, parent)) {
            node[1]['class'] = 'onebox';
            node[1].target = '_blank';

            // TODO:
            // if (Discourse && Discourse.Onebox) {
            //   onebox = Discourse.Onebox.lookupCache(url);
            // }
          }
        };

        // Escape the contents of code blocks
        var parseCode = function(node, path) {
          node[node.length-1] = Handlebars.Utils.escapeExpression(node[node.length-1]);
        };

        var parseNode = function(tree, path) {
          if (tree instanceof Array) {
            var nodes = tree.slice(1);

            if (tree[0] === 'a') {
              parseLink(tree, path);
            }

            if (tree[0] === 'code') {
              parseCode(tree, path);
            }

            path = path || [];
            path.push(tree);
            nodes.forEach(function (n) {
              parseNode(n, path);
            });
            path.pop();
          }
        };

        var htmlTree = window.BetterMarkdown.toHTMLTree(text, 'Discourse');
        parseNode(htmlTree);
        text = window.BetterMarkdown.renderJsonML(htmlTree);

        if (!text) return "";

        // don't do @username mentions inside <pre> or <code> blocks
        text = text.replace(/<(pre|code)>([\s\S](?!<(pre|code)>))*?@([\s\S](?!<(pre|code)>))*?<\/(pre|code)>/gi, function(m) {
          return m.replace(/@/g, '&#64;');
        });

        var mentionLookup = opts.mentionLookup || Discourse.Mention.lookupCache;

        // add @username mentions, if valid; must be bounded on left and right by non-word characters
        text = text.replace(/(\W)(@[A-Za-z0-9][A-Za-z0-9_]{2,14})(?=\W)/g, function(x, pre, name) {
          if (mentionLookup(name.substr(1))) {
            return pre + "<a href='" + Discourse.getURL("/users/") + (name.substr(1).toLowerCase()) + "' class='mention'>" + name + "</a>";
          } else {
            return pre + "<span class='mention'>" + name + "</span>";
          }
        });

        if (opts.sanitize) {
          if (!window.sanitizeHtml) return "";
          text = window.sanitizeHtml(text);
        }

        return text;
      }
    };
  }

};
RSVP.EventTarget.mixin(Discourse.Markdown);
