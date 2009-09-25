// var trans = new Transcript('#timeline', '#trans', '#extra', '#vid-nav','#vid-tabs', '#rail', '#viewer', window.location);

(function() {
  
  // Extend jQuery with the ability to preload images.
  $.extend({
    preloadImages : function() {
      $.each(arguments, function() {
        $("<img>").attr("src", this);
      });
    }
  });
  
  // The top-level VidSkim namespace.
  window.VidSkim = {
    
    // Start up the video skimmer, attaching its behavior to the DOM.
    start : function() {
      this.initted     = false;
      this.data        = null;
      this.texts       = [];
      this.max         = 0;
      this.mode        = 'transcript';
      this.hashSeconds = parseInt(window.location.hash.replace('#', ''), 10) || 0;
      this.baseURL     = window.location.href.replace(window.location.hash, '');
      
      this.timeline    = $('#timeline');
      this.trans       = $('#trans');
      this.extra       = $('#extra');
      this.nav         = $('#vid-nav');
      this.tabs        = $('#vid-tabs');
      this.rail        = $('#rail');
      this.viewer      = $('#viewer');
    },
    
    // ...
    setData : function(data) {
      this.data = data;
      // if this.initted ... buildTimeline ?
      for (mode in this.data) {
        $.each(this.data[mode].entries, function() {
          this.range[0] = VidSkim.parseTimeCode(this.range[0]);
          this.range[1] = VidSkim.parseTimeCode(this.range[1]);
        });
      }
    },
    
    // Parse an 'hh:mm:ss' formatted time-code into the number of seconds.
    parseTimeCode : function(timeCode) {
      var times   = timeCode.split(':');
      var hours   = parseInt(times[0], 10);
      var minutes = parseInt(times[1], 10);
      var seconds = parseInt(times[2], 10);
      return hours * 60 * 60 + minutes * 60 + seconds;
    },
    
    // Toggle between modes of the VidSkim -- 'transcript' or 'annotations'.
    setMode : function(mode) {
      this.mode = mode;
      $('a#tab-' + this.mode, this.tabs).addClass('active');
      $('div', this.rail).hide();
      $('div.' + this.paramaterize(this.mode), this.rail).show();
    },
    
    // Convert an arbitrary string into a dom-ready attribute name.
    paramaterize: function(string) {
      return string.toLowerCase().replace(/\W/g, '');
    }
    
  };
  
})();