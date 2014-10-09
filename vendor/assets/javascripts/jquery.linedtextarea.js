/**
 * jQuery Lined Textarea Plugin
 *   http://alan.blog-city.com/jquerylinedtextarea.htm
 *
 * Copyright (c) 2010 Alan Williamson
 *
 * Version:
 *    $Id: jquery-linedtextarea.js 464 2010-01-08 10:36:33Z alan $
 *
 * Released under the MIT License:
 *    http://www.opensource.org/licenses/mit-license.php
 *
 * Usage:
 *   Displays a line number count column to the left of the textarea
 *
 *   Class up your textarea with a given class, or target it directly
 *   with JQuery Selectors
 *
 *   $(".lined").linedtextarea({
 *   	selectedLine: 10,
 *    selectedClass: 'lineselect'
 *   });
 *
 * History:
 *   - 2010.01.08: Fixed a Google Chrome layout problem
 *   - 2010.01.07: Refactored code for speed/readability; Fixed horizontal sizing
 *   - 2010.01.06: Initial Release
 *
 */
(function($) {

	$.fn.linedtextarea = function(options) {

		// Get the Options
		var opts = $.extend({}, $.fn.linedtextarea.defaults, options);


		/*
		 * Helper function to make sure the line numbers are always
		 * kept up to the current system
		 */
		var fillOutLines = function(codeLines, h, lineNo, totalLines){
			while ( lineNo <= totalLines ) {
				if ( lineNo == opts.selectedLine )
					codeLines.append("<div class='lineno lineselect'>" + lineNo + "</div>");
				else
					codeLines.append("<div class='lineno'>" + lineNo + "</div>");

				lineNo++;
			}
			return lineNo;
		};


		/*
		 * Iterate through each of the elements are to be applied to
		 */
		return this.each(function() {
			var lineNo = 1;
			var textarea = $(this);

			var totalLines = textarea.val().trim().split(/\n/).length;

			/* Turn off the wrapping of as we don't want to screw up the line numbers */
			textarea.attr("wrap", "off");

			/* Wrap the text area in the elements we need */
			textarea.wrap("<div class='linedtextarea'></div>");
			var linedTextAreaDiv	= textarea.parent().wrap("<div class='linedwrap' style='width:100%'></div>");
			var linedWrapDiv 			= linedTextAreaDiv.parent();

			linedWrapDiv.prepend("<div class='lines' style='width:50px'></div>");

			var linesDiv	= linedWrapDiv.find(".lines");
			linesDiv.height( textarea.height() + 6 );


			/* Draw the number bar; filling it out where necessary */
			linesDiv.append( "<div class='codelines'></div>" );
			var codeLinesDiv	= linesDiv.find(".codelines");
			lineNo = fillOutLines( codeLinesDiv, linesDiv.height(), 1, totalLines );

			/* Move the textarea to the selected line */
			if ( opts.selectedLine != -1 && !isNaN(opts.selectedLine) ){
				var fontSize = parseInt( textarea.height() / (lineNo-2) );
				var position = parseInt( fontSize * opts.selectedLine ) - (textarea.height()/2);
				textarea[0].scrollTop = position;
			}


			/* Set the width of the textarea */
			var resizeTextarea = function() {
				var fullWidth            = linedWrapDiv.outerWidth();
				var sidebarWidth         = linesDiv.outerWidth();
				var paddingHorizontal    = parseInt( linedWrapDiv.css("border-left-width") ) + parseInt( linedWrapDiv.css("border-right-width") ) + parseInt( linedWrapDiv.css("padding-left") ) + parseInt( linedWrapDiv.css("padding-right") );
				var linedWrapDivNewWidth = fullWidth - paddingHorizontal;
				var textareaNewWidth     = fullWidth - sidebarWidth - paddingHorizontal - 20;

				textarea.width( textareaNewWidth );
				// linedWrapDiv.width( linedWrapDivNewWidth );
			};
			resizeTextarea();
			$(window).resize(resizeTextarea);


			/* React to the scroll event */
			textarea.scroll( function(tn){
				var domTextArea		= $(this)[0];
				var scrollTop 		= domTextArea.scrollTop;
				var clientHeight 	= domTextArea.clientHeight;
				codeLinesDiv.css( {'margin-top': (-1*scrollTop) + "px"} );
				lineNo = fillOutLines( codeLinesDiv, scrollTop + clientHeight, lineNo, totalLines );
			});


			/* Should the textarea get resized outside of our control (by dragging the grabber) */
			// workaround for a lack of a resize event on textareas using the native resize control
			// via http://stackoverflow.com/a/7055239
			textarea.data('x', textarea.outerWidth());
			textarea.data('y', textarea.outerHeight());
			textarea.on("mousemove mouseup", function(tn) {
				var $this = jQuery(this);
				if ($this.outerWidth() != $this.data('x') || $this.outerHeight() != $this.data('y')) {
					linesDiv.height( $this[0].clientHeight + 6 );
				}
				$this.data('x', $this.outerWidth());
				$this.data('y', $this.outerHeight());
			});

		});
	};

	// default options
	$.fn.linedtextarea.defaults = {
		selectedLine: -1,
		selectedClass: 'lineselect'
	};
})(jQuery);
