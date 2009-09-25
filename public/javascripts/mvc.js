window.trans = {
  
  initialize:function (){
    //defaults go here
    this._view_cache = {}
    this.model = new trans.modelConstructor();
    this.controller = new trans.controllerConstructor();
    this.view = new trans.viewConstructor();
  },
  ///////////
  // class constructor stubs
  /////////// 
  modelConstructor: function (){
    var model = {
      init:function() {
      }
    }
    return model;
  },
  
  controllerConstructor: function () {
    var controller = {
      init: function(){
      },
      addEvent: function(id, ev, fn) {
        $(id).live(ev, fn);
      }
    }
    return controller;
  },
  
  viewConstructor: function(){
    var view = {
      render: function(id, data){
        // care of john resig
        // Figure out if we're getting a template, or if we need to
        // load the template - and be sure to cache the result.
        var fn = !/\W/.test(id) ?
          trans._view_cache[id] = Transcript._view_cache[id] ||
            Transcript.view(document.getElementById(id).innerHTML) :

          // Generate a reusable function that will serve as a template
          // generator (and which will be cached).
        new Function("obj",
            "var p=[],print=function(){p.push.apply(p,arguments);};" +

            // Introduce the data as local variables using with(){}
            "with(obj){p.push('" +

            // Convert the template into pure JavaScript
            str
              .replace(/[\r\t\n]/g, " ")
              .split("{%").join("\t")
              .replace(/((^|%>)[^\t]*)'/g, "$1\r")
              .replace(/\t=(.*?)%>/g, "',$1,'")
              .split("\t").join("');")
              .split("%}").join("p.push('")
              .split("\r").join("\\'")
          + "');}return p.join('');");

        // Provide some basic currying to the user
        return data ? fn( data ) : fn;
      }
    }
    return view;
  },
  
  ///////
  // class methods and variables
  ///////
  request: function (action, id){   
    trans.controller[action].id;
  }
};
//////
// initialize base trans object
//////
trans.initialize();

///////
// Adding trans class methods
///////
$.extend(trans, {

});

///////
// building classes
//////
$.extend(trans.model, {
  // initializes the model with data from json
  setData: function(raw_data){
    this.raw_data = raw_data;
  },
  
  // set's the current view
  setDefault: function(key){
    this.data = raw_data[key];
    this.parseData();
  },
  
  // parses the data into pure seconds
  parseData: function(){
    $.each(trans.model.data, function(){
      $.each(this.entries, function(){
        this.range[0] = trans.model.timeCodeParse(this.range[0]);
        this.range[1] = trans.model.timeCodeParse(this.range[1]);
      });
    });
  },
  
  //the brains of the operation, a binary search that can handle arbitrary ranges of data, returns the next and previous items if asked nicely
  lookup: function(time, nearest){  lookup: function(seconds, nearest){
    var ret = [];
    var nearest = nearest || false;
    $.each(trans.model.data, function(i,val){
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
         
         if(this.entries[start] && 
            this.entries[start].range[0] <= time &&
            this.entries[start].range[1] >= time){ 
            // case 1: in a clip
            ret.push([before, after]);
         } else if(start == 0) { // case 3: before any clips
            ret.push([first, first]);
         } else if(this.entries[start] && 
            this.entries[start-1].range[1] < time &&
            this.entries[start].range[0] > time) { 
            // case 2: in between clips
            ret.push([before, found]);
         } else if(start >= end){ // case 4: after any clips
            ret.push([last,last]);
         }
       } else {
         if (this.entries[start] && 
             this.entries[start].range[0] <= time &&
             this.entries[start].range[1] >= time) {
             var find = this.entries[start];
             find.css_class = i;
             ret.push(find);
         }
      }
  },
  
  //parsing into integer-seconds from "hh:mm:ss" format
  timeCodeParse: function(timeCode){
    var times = timeCode.split(':');
    var hours = parseInt(times[0], 10);
    var minutes = parseInt(times[1], 10);
    var seconds = parseInt(times[2], 10);
    return hours*60*60 + minutes*60 + seconds;
  }
  
});

$.extend(trans.controller, {
  // render the timeline view
  timeline: function(){
    trans.view.render("#timeline", trans.model.data)
  },
  
  //convenience caller to seekToIndex
  next: function(){
    trans.controller.seekToIndex(1);
  },
  //convenience caller to seekToIndex
  previous: function(){
    trans.controller.seekToIndex(0);
  },
  
  seekToIndex: function(offset) {
    var time = trans.player.getCurrentTime();
    var entries = trans.model.lookup(time, true);
    if(entries[0][offset]){
      trans.player.seek(entries[0][offset].range[0]);
    }
  }
  
  
});



//////
// create and set events
/////
trans.controller.addEvent('#timeline', 'click', function (){ 'test' });

