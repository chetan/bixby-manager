// TemplateJS v3.1.1 MIT/GPL2 @jon_neal
// https://gist.github.com/jonathantneal/1651891
(function (global) {
	function escapeJS (str) {
		return str.replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/\r/g, '\\r');
	}

	function TemplateWalk (str, chars, helpers, instance) {
		// check for the opening delimiters and init our array buffer
		var index = str.indexOf(chars.START_PROP), buffer = '', helper;

		// if the opening delimiters are encountered
		if (index > -1) {
			// add to the buffer the contents before the opening delimiters
			buffer += '__out__+="' + escapeJS(str.substr(0, index)) + '";';

			// move the string to after the opening delimiters
			str = str.substr(index + chars.START_PROP.length);

			// get the helper character of the string
			helper = str.substr(0, 1);

			// get the index of the closing delimiters
			index = str.indexOf(chars.END_PROP);

			// if the closing delimiters are encountered
			if (index > -1) {
				// if the helper function does exist
				if (helpers[helper]) {
					// add to the buffer the return of the helper function
					buffer += helpers[helper].call(instance, str.substr(helper.length, index - helper.length));

					// move the string to after the closing delimiters
					str = str.substr(index + chars.END_PROP.length);

					// add to the buffer the return of this function
					buffer += TemplateWalk(str, chars, helpers, instance);
				}
				// if the helper function does not exist
				else {
					// add to the buffer the contents before the closing delimiters
					buffer += str.substr(0, index);

					// add to the buffer the return of this function
					buffer += TemplateWalk(str.substr(index + chars.END_PROP.length), chars, helpers, instance);
				}
			}
		}
		// if the opening delimiters are not encountered
		else {
			buffer += '__out__+="' + escapeJS(str) + '";';
		}

		// return the buffer
		return buffer;
	}

	function Template (val) {
		var instance = this, data = instance.data = {
			template: '',
			compiled: function () {},
			cached: ''
		}, delimiters = instance.delimiters = {
			'START_PROP': '<%',
			'END_PROP': '%>'
		}, helpers = instance.helpers = {
			'=': function (js) {
				// output js
				return '__out__+=' + js + ';';
			},
			'-': function (js) {
				// output js if defined
				return 'if (' + js + '){__out__+=' + js + '}';
			},
			'?': function (js) {
				// open if block around js w/ test for not-null value
				var m = js.match(/^(.*?)([&|]{2}.*)$/);
				if (m) {
					return '{if(typeof(' + m[1] + ') !== "undefined" && ' + m[1] + m[2] + '){';
				}
				return '{if(typeof(' + js + ') !== "undefined" && ' + js + '){';
			},
			'!': function (js) {
				// open if block around !js
				return '{if(!(' + js + ')){';
			},
			'#': function (js) {
				// open for/with loop on an object 'js'
				return 'for(var __property__ in ' + js + '){with(' + js + '[__property__]){';
			},
			'@': function (js) {
				// open with block on object 'js'
				return '{with(' + js + '){';
			},
			'/': function (js) {
				// close open brackets
				return '}}';
			}
		}

		instance.template = function (val) {
			if (val === undefined) {
				return data.template;
			} else {
				if (val !== data.template) {
					data.template = val;

					data.compiled = Function((
						'__out__="";with(this){' + TemplateWalk(val, delimiters, helpers, instance) + '}return __out__;'
					).replace(/;__out__\+=/g, '+'));

					delete data.cached;
				}

				return instance;
			}
		};

		instance.context = function (val) {
			if (val === undefined) {
				return data.context;
			} else {
				if (val !== data.context) {
					data.context = val;

					delete data.cached;
				}

				return instance;
			}
		};

		instance.render = function (val) {
			if (val !== undefined) {
				instance.context(val);
			}

			return data.cached !== undefined ? data.cached : data.cached = data.compiled.call(data.context);
		};

		if (val) {
			instance.template(val);
		}

		return instance;
	}

	global.Template = Template;
})(this);
