// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery.fn.sort = function(){
  return this.pushStack(jQuery.makeArray([].sort.apply(this, arguments)));
};
$(function(){
  var list = $("ul.comics");
  $("*[data-sort-by]").click(function(){
    var sort_by = $(this).attr("data-sort-by");
  });
});
