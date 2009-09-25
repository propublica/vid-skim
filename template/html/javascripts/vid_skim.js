/*
###### Preloader
*/
jQuery.preloadImages = function()
{
  $.each(arguments, function (){
    jQuery("<img>").attr("src", this);
  });
}

/*
###### Transcript
*/
function defineTranscript($) {
  var transcript = function (timeline_id, trans_id, extra_id, nav_id, tab_id, rail_id, viewer_id, location) { /* TK params should be hasherized */
    this.current_texts = [];
    this.timeline_id = timeline_id;
    this.trans_id = trans_id;
    this.extra_id = extra_id;
    this.rail_id = rail_id;
    this.nav_id = nav_id;
    this.tab_id = tab_id;
    this.viewer_id = viewer_id;
    this.max = 0;
    this.hashSeconds = parseInt(location.hash.replace("#", ''), 10) || 0;
    this.baseURL = location.href.replace(location.hash, '');
    this.initted = false;
  };
  transcript.prototype = {
    init: function(){    
    },
    
    // central dispatch for data setting and view switching
    setData: function(raw_data, key) {
      this.raw_data = raw_data || this.raw_data;
      var temp = {}
      temp[key] = this.raw_data[key];
      this.parsed_data = temp;      
      transcript = this;
      $(this.tab_id + " a#tab-" + key).addClass('active');
      $(this.rail_id + " div").hide();
      $(this.rail_id + " div." + this.parametize(key)).show();
      if (this.initted){ /* for tabs */
        this.buildTimeline();
      } else {
        $.each(this.raw_data, function(){
          $.each(this.entries, function() {
            this.range[0] = transcript.timeCodeParse(this.range[0]);
            this.range[1] = transcript.timeCodeParse(this.range[1]);
          });
        });
      }
    },
    
    //called after we know the length of the video
    setBounds: function(max) {
      if(this.max === 0){
        this.max = max;
  		  this.initTimeLine();
        this.draw(0);
      }
    },
    
    //convienence method and hook for possible support of other players
    setPlayer: function(player) {
      this.player = player;
    },
    
    //handles all construction of extra html elements, as well as initializing mouse listeners
    initTimeLine: function(){
      /* scrubber and timeline */
      var scrubber_selector = this.timeline_id + " div.scrubber";
      var timeline = this.timeline_id;
      
		  var max = this.max;
		  var transcript = this;
      $(scrubber_selector).hide();
	    $(this.timeline_id).mouseover(function(){$(scrubber_selector).show();});
	    $(this.timeline_id).mousemove(function(e) {
		    var x_real = e.clientX - $(timeline).offset().left;
		    var titles = transcript.lookup(Math.floor(x_real*max/$(timeline).width()));
		    if(!transcript.curr_titles.range[0] || 
		      titles.range[0] != 
		      transcript.curr_titles.range[0]) {
		      transcript.curr_titles = titles;
		      if (transcript.curr_titles[0]) {
		        $(scrubber_selector).html(transcript.curr_titles[0].title);
	        } else {
	          $(scrubber_selector).html('');
	        }
		    }
		    if (x_real < $(timeline).width()){
		      $(scrubber_selector).css({'left': x_real-5});
		    }
		  });
		  $(this.timeline_id).click(function(e){
		    var x_real = e.clientX - $(timeline).offset().left;
		    var seconds = Math.floor(x_real*max/$(timeline).width());
		    seconds = transcript.lookup(seconds).length ?
		              transcript.lookup(seconds)[0].range[0] : seconds;
		    transcript.seek(seconds);
		  });
		  $(this.timeline_id).mouseleave(function(){
		    $(scrubber_selector).hide();
		  });
		  
		  /*navigation*/
		  $.each(["Next", "Previous"], function() {
		     $(transcript.nav_id + " a." + this.toLowerCase()).click(function (e){
		       transcript[$(this).attr('class')]();
		       return false;
		     });
		  });
		  
		  $("a.index").click(function (e){
		    transcript.seek(parseInt($(this).attr('href').replace('#', ''), 10));
		    return false;
		  });
		  $.each(this.raw_data, function(i, val){
		    $(transcript.tab_id + ' a#tab-' + i).
		    prepend("<span class=\"color\" style=\"border-color:" + 
		              val.color + "; background-color:" +
		              val.color +  "\">&nbsp;</span>&nbsp;") 
		  });
		  $(this.tab_id + ' a').click(function (e){
        if(transcript.current_tab != $(this).attr('id').replace("tab-", '')){
          transcript.current_tab = $(this).attr('id').replace("tab-", '');
          $(transcript.tab_id + " a").removeClass('active');
          transcript.setData(null, $(this).attr('id').replace("tab-", ''));
        }
        return false;
      });
      
		  /*height calculations*/
		  var height = $(this.rail_id).height()-60;
		  $(this.viewer_id).css({'height':height+'px'});
		  $(this.trans_id).css({'height':height-60+'px'});
		  
		  
		  this.buildTimeline();  
    },
    // refreshes the timeline each time setData is called.
    buildTimeline: function (){
      /* boxes */
      var timeline = this.timeline_id;
      var max = this.max;
		  var transcript = this;
      $(this.timeline_id + " div.time_box").remove();
      
		  $.each(this.parsed_data, function (i, val) {
		    $.each(this.entries, function() {
		      $(timeline).append('<div class="' + i + ' ' + transcript.parametize(this.title) + ' time_box" style="left:'+ Math.floor(this.range[0]*$(timeline).width()/max) + 'px; width:' + (Math.floor(this.range[1]*$(timeline).width()/max) - Math.floor(this.range[0]*$(timeline).width()/max)) + 'px">&nbsp;</span>');
          
		    });
        $('div.' + i).css({
          'background-color': val.color
        });
        $('div.' + i).hover(function(){
          transcript.highlightSection();
          $(this).css({'background-color':val.hover});
        }, function(){
          $(this).css({'background-color':val.color});
          transcript.highlightSection();
        });
		  });
    },
    
    //highlights the current section on the timeline
    highlightSection: function(){
      if(this.current_texts[0]) {
        $('#timeline .time_box').css({
          'background-color':
          this.parsed_data[this.current_texts[0].css_class].color  
        })
        $('#timeline .'+
         this.parametize(this.current_texts[0].title)).css({
          'background-color':
           this.parsed_data[this.current_texts[0].css_class].hover
        });
      }
    },
    
    //convenience method for working with hash keys
    parametize: function (str) {
      var t = str;
      return t.toLowerCase().replace(/\W/g, '')
    },
    
    //rerenders the current view as needed
    draw: function(time){
      if(this.initted){
        var texts = this.lookup(time);
        if(!transcript.curr_titles.range[0] || 
		      titles.range[0] != 
		      transcript.curr_titles.range[0]){ /* transcript */
          this.current_texts = texts;
          var trans_all = "<ul>"; var extra_all = "<ul>";
          if(this.current_texts[0]){
            /* index highlighting */
            transcript.highlightSection();
            
            $('a.index').removeClass('active');
            $('a.index.' + this.parametize(this.current_texts[0].title))
              .addClass('active');
            
            
            /* transcript building */
            $.each(this.current_texts, function(){
              trans_all = trans_all + '<li class="trans ' + this.css_class + '">' + this.transcript + "</li>";
              if (this.extra){
                extra_all = extra_all + '<li class="extra ' + this.css_class + '">' + this.extra + "</li>";
              } 
            });

            $(this.trans_id).html(extra_all + "</ul>" + trans_all + "</ul>");
          } else {
            
            $(this.trans_id).html('');
          }
          
          if(this.current_texts[0] && Math.floor(this.current_texts[0].range[0]) > 0){
            var new_seconds = Math.floor(this.current_texts[0].range[0]);
            if(new_seconds != this.hashSeconds){
              this.hashSeconds = Math.floor(this.current_texts[0].range[0]);
              window.location.href = trans.baseURL + "#" + this.hashSeconds;
            }
          }
          
        }
        $(this.timeline_id + " div.position").css({'left':this.player.getCurrentTime()*$(this.timeline_id).width()/this.max});
      }
    },
    
    //convenience caller to seekToIndex
    next: function(){
      this.seekToIndex(1);
    },
    //convenience caller to seekToIndex
    previous: function(){
      this.seekToIndex(0);
    },
    
    seekToIndex: function(offset) {
      var time = this.player.getCurrentTime();
      var entries = this.lookup(time, true);
      if(entries[0][offset]){
        this.seek(entries[0][offset].range[0]);
      }
    },
    //the brains of the operation, a binary search that can handle arbitrary ranges of data, returns the next and previous items if asked nicely
    lookup: function(time, nearest){
      var ret = [];
      var nearest = nearest || false;
      $.each(this.parsed_data, function(i,val){
        var start = 0;
        var end = this.entries.length;
        while (start < end) {
           var mid = Math.floor((start+end)/2);
           if (this.entries[mid].range[1] < time) {
             start = mid+1;
           } else {
             end = mid;
           }
         }
         if (nearest){
           var before = this.entries[start-1];
           var after = this.entries[start+1];
           var found = this.entries[start];
           var first = this.entries[0]
           var last = this.entries[this.entries.length-1];
           
           if(this.entries[start] && this.entries[start].range[0] <= time && this.entries[start].range[1] >= time){ // case 1: in a clip
             ret.push([before, after]);
           } else if(start == 0) { // case 3: before any clips
             ret.push([first, first]);
           } else if(this.entries[start] && this.entries[start-1].range[1] < time && this.entries[start].range[0] > time) { // case 2: in between clips
             ret.push([before, found]);
           } else if(start >= end){ // case 4: after any clips
             ret.push([last,last]);
           }
         } else {
           if (this.entries[start] && this.entries[start].range[0] <= time && this.entries[start].range[1] >= time) {
             var find = this.entries[start];
             find.css_class = i;
             ret.push(find);
           }
        }
      });
      return ret;
    },
    //parsing into integers from "hh:mm:ss" format
    timeCodeParse: function(timeCode){
      var times = timeCode.split(':');
      var hours = parseInt(times[0], 10);
      var minutes = parseInt(times[1], 10);
      var seconds = parseInt(times[2], 10);
      return hours*60*60 + minutes*60 + seconds;
    },
    
    //wrapper function
    seek: function(time) { 
      this.player.seekTo(time+1, true); 
    }
  };
  return transcript;
}
// all that for this.
var Transcript = defineTranscript($);