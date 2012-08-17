// Generated by CoffeeScript 1.3.1
(function() {

  _.templateSettings = {
    interpolate: /\{\{(.+?)\}\}/g
  };

  this.CrosshairSelector = Backbone.View.extend({
    className: "crosshair-selector",
    height: 200,
    width: 200,
    dotSize: 10,
    notchSpacing: 10,
    notchWidth: 10,
    _mouseState: false,
    template: _.template("<canvas class='bg' height=\"{{height}}\" width=\"{{width}}\"></canvas>\n<canvas class='fg' height=\"{{height}}\" width=\"{{width}}\"></canvas>"),
    generateBackground: function() {
      var ctx, end, height, i, j, node, origin, start, width;
      node = this.$('.bg')[0];
      ctx = node.getContext('2d');
      height = node.height;
      width = node.width;
      origin = [node.width / 2, node.height / 2];
      ctx.beginPath();
      ctx.moveTo(width / 2, 0);
      ctx.lineTo(width / 2, height);
      ctx.moveTo(0, height / 2);
      ctx.lineTo(width, height / 2);
      i = j = origin[0];
      start = origin[1] - this.notchWidth / 2;
      end = origin[1] + this.notchWidth / 2;
      while (i <= width) {
        i += this.notchSpacing;
        j -= this.notchSpacing;
        ctx.moveTo(i, start);
        ctx.lineTo(i, end);
        ctx.moveTo(j, start);
        ctx.lineTo(j, end);
      }
      i = j = origin[1];
      start = origin[0] - this.notchWidth / 2;
      end = origin[0] + this.notchWidth / 2;
      while (i <= height) {
        i += this.notchSpacing;
        j -= this.notchSpacing;
        ctx.moveTo(start, i);
        ctx.lineTo(end, i);
        ctx.moveTo(start, j);
        ctx.lineTo(end, j);
      }
      ctx.stroke();
    },
    setCrosshair: function(e) {
      var ctx, mousePos, node, x, y;
      e.preventDefault();
      node = this.$(".fg")[0];
      ctx = node.getContext('2d');
      mousePos = h337.util.mousePosition(e);
      if (mousePos == null) {
        return;
      }
      x = Math.max(0, Math.min(mousePos[0], node.width));
      y = Math.max(0, Math.min(mousePos[1], node.height));
      ctx.clearRect(0, 0, node.width, node.height);
      ctx.beginPath();
      ctx.moveTo(x - this.dotSize, y);
      ctx.lineTo(x + this.dotSize, y);
      ctx.moveTo(x, y - this.dotSize);
      ctx.lineTo(x, y + this.dotSize);
      ctx.stroke();
      this._heatmap.store.addDataPoint(x, y);
      return this.coords = {
        x: x,
        y: y
      };
    },
    setCoordText: function() {
      var availableWidth, node, textCtx, textSize;
      node = this.$(".bg")[0];
      textCtx = node.getContext('2d');
      textSize = node.height / 20;
      availableWidth = node.width / 2 - this.notchWidth / 2;
      textCtx.clearRect(0, 0, availableWidth, textSize * 2);
      textCtx.font = "" + textSize + "px monospace";
      textCtx.textBaseline = "top";
      return textCtx.fillText("(" + this.coords.x + ", " + this.coords.y + ")", 3, 3);
    },
    showHeatmap: function() {
      return $(this._heatmap.get('canvas')).show();
    },
    hideHeatmap: function() {
      return $(this._heatmap.get('canvas')).hide();
    },
    events: {
      "mousedown": function(e) {
        this._mouseState = true;
        this.setCrosshair(e);
        return this.setCoordText();
      }
    },
    setGlobalEvents: function() {
      var self;
      self = this;
      $(window).on("mouseup", function(e) {
        return (function(e) {
          if (!this._mouseState) {
            return;
          }
          this._mouseState = false;
          $(".canvas-filter").remove();
          return $("body").css('cursor', '');
        }).call(self, e);
      });
      return $(window).on("mousemove", function(e) {
        return (function(e) {
          if (!this._mouseState) {
            return;
          }
          $('body').css('cursor', 'move');
          this.setCrosshair(e);
          return this.setCoordText();
        }).call(self, e);
      });
    },
    initialize: function(obj) {
      if (obj == null) {
        obj = {};
      }
      if (obj.height != null) {
        this.height = parseInt(obj.height, 10);
      }
      if (obj.width != null) {
        this.width = parseInt(obj.width, 10);
      }
      if (obj.dotSize != null) {
        this.dotSize = parseInt(obj.dotSize, 10);
      }
      if (obj.notchSpacing != null) {
        this.notchSpacing = parseInt(obj.notchSpacing, 10);
      }
    },
    render: function() {
      this.$el.empty().append(this.template({
        height: this.height,
        width: this.width
      })).css({
        height: this.height,
        width: this.width
      });
      this.$el.children().css({
        height: this.height,
        width: this.width
      });
      this.generateBackground();
      this.setGlobalEvents();
      this._heatmap = h337.create({
        element: this.el,
        radius: 15,
        visible: false
      });
      this._heatmap.get('canvas').style.zIndex = 0;
      return this;
    }
  });

}).call(this);
