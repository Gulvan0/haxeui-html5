package haxe.ui.backend.html5;

import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ComponentImpl;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Slice9;
import haxe.ui.styles.Style;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Element;
import js.html.Image;

class StyleHelper {
    @:access(haxe.ui.core.ComponentImpl)
    public static function apply(component:ComponentImpl, width:Float, height:Float, style:Style) {
        var element:Element = component.element;
        var css:CSSStyleDeclaration = element.style;

        css.width = HtmlUtils.px(width);
        css.height = HtmlUtils.px(height);

        // border size
        if (style.borderLeftSize != null &&
            style.borderLeftSize == style.borderRightSize &&
            style.borderLeftSize == style.borderBottomSize &&
            style.borderLeftSize == style.borderTopSize) { // full border

            if (style.borderLeftSize > 0) {
                css.borderWidth = HtmlUtils.px(style.borderLeftSize);
                css.borderStyle = "solid";
            } else {
                css.removeProperty("border-width");
                css.removeProperty("border-style");
            }
        } else if (style.borderLeftSize == null &&
            style.borderRightSize == null &&
            style.borderBottomSize == null &&
            style.borderTopSize == null) { // no border
            css.removeProperty("border-width");
            css.removeProperty("border-style");
        } else { // compound border
            if (style.borderTopSize != null && style.borderTopSize > 0) {
               css.borderTopWidth = HtmlUtils.px(style.borderTopSize);
               css.borderTopStyle = "solid";
            } else {
                css.removeProperty("border-top-width");
                css.removeProperty("border-top-style");
            }

            if (style.borderLeftSize != null && style.borderLeftSize > 0) {
               css.borderLeftWidth = HtmlUtils.px(style.borderLeftSize);
               css.borderLeftStyle = "solid";
            } else {
                css.removeProperty("border-left-width");
                css.removeProperty("border-left-style");
            }

            if (style.borderBottomSize != null && style.borderBottomSize > 0) {
               css.borderBottomWidth = HtmlUtils.px(style.borderBottomSize);
               css.borderBottomStyle = "solid";
            } else {
                css.removeProperty("border-bottom-width");
                css.removeProperty("border-bottom-style");
            }

            if (style.borderRightSize != null && style.borderRightSize > 0) {
               css.borderRightWidth = HtmlUtils.px(style.borderRightSize);
               css.borderRightStyle = "solid";
            } else {
                css.removeProperty("border-right-width");
                css.removeProperty("border-right-style");
            }
        }

        // border colour
        if (style.borderLeftColor != null &&
            style.borderLeftColor == style.borderRightColor &&
            style.borderLeftColor == style.borderBottomColor &&
            style.borderLeftColor == style.borderTopColor) {

            if (style.borderOpacity == null) {
                css.borderColor = HtmlUtils.color(style.borderLeftColor);
            } else {
                css.borderColor = HtmlUtils.rgba(style.borderLeftColor, style.borderOpacity);
            }
        } else if (style.borderLeftColor == null &&
            style.borderRightColor == null &&
            style.borderBottomColor == null &&
            style.borderTopColor == null) {
            css.removeProperty("border-color");
        } else {
            if (style.borderTopColor != null) {
               css.borderTopColor = HtmlUtils.color(style.borderTopColor);
            } else {
                css.removeProperty("border-top-color");
            }

            if (style.borderLeftColor != null) {
               css.borderLeftColor = HtmlUtils.color(style.borderLeftColor);
            } else {
                css.removeProperty("border-left-color");
            }

            if (style.borderBottomColor != null) {
               css.borderBottomColor = HtmlUtils.color(style.borderBottomColor);
            } else {
                css.removeProperty("border-bottom-color");
            }

            if (style.borderRightColor != null) {
               css.borderRightColor = HtmlUtils.color(style.borderRightColor);
            } else {
                css.removeProperty("border-right-color");
            }
        }

        // background
        var background:Array<String> = [];
        if (style.backgroundColors != null && style.backgroundColors.length > 0) {
            css.removeProperty("background-color");
            if (style.backgroundColors.length == 1) { // solid
                if (style.backgroundOpacity != null) {
                    css.backgroundColor = HtmlUtils.rgba(style.backgroundColors[0].color, style.backgroundOpacity);
                } else {
                    css.backgroundColor = HtmlUtils.color(style.backgroundColors[0].color);
                }
            } else { // gradient
                var gradientStyle = style.backgroundGradientStyle;
                if (gradientStyle == null) {
                    gradientStyle = "vertical";
                }
                
                var linearGradientFromTo = "to bottom";
                if (gradientStyle == "horizontal") {
                    linearGradientFromTo = "to right";
                }
                
                var gradientParts:Array<String> = [];
                for (backgroundPair in style.backgroundColors) {
                    if (style.backgroundOpacity != null) {
                        gradientParts.push('${HtmlUtils.rgba(backgroundPair.color, style.backgroundOpacity)} ${backgroundPair.location}%');
                    } else {
                        gradientParts.push('${HtmlUtils.color(backgroundPair.color)} ${backgroundPair.location}%');
                    }
                }
                
                background.push('linear-gradient(${linearGradientFromTo}, ${gradientParts.join(",")})');
            }
        }
        
        if (style.borderRadius != null && style.borderRadius > 0) {
            css.borderRadius = HtmlUtils.px(style.borderRadius);
        } else {
            css.removeProperty("border-radius");
        }

        // background image
        if (style.backgroundImage != null) {
            if (component.element.nodeName == "BUTTON") {
                css.border = "none";
            }

            Toolkit.assets.getImage(style.backgroundImage, function(imageInfo:ImageInfo) {
                if (imageInfo == null) {
                    return;
                }

                var imageRect:Rectangle = new Rectangle(0, 0, imageInfo.width, imageInfo.height);
                if (style.backgroundImageClipTop != null &&
                    style.backgroundImageClipLeft != null &&
                    style.backgroundImageClipBottom != null &&
                    style.backgroundImageClipRight != null) {
                        imageRect = new Rectangle(style.backgroundImageClipLeft,
                                                  style.backgroundImageClipTop,
                                                  style.backgroundImageClipRight - style.backgroundImageClipLeft,
                                                  style.backgroundImageClipBottom - style.backgroundImageClipTop);
                }

                var slice:Rectangle = null;
                if (style.backgroundImageSliceTop != null &&
                    style.backgroundImageSliceLeft != null &&
                    style.backgroundImageSliceBottom != null &&
                    style.backgroundImageSliceRight != null) {
                    slice = new Rectangle(style.backgroundImageSliceLeft,
                                          style.backgroundImageSliceTop,
                                          style.backgroundImageSliceRight - style.backgroundImageSliceLeft,
                                          style.backgroundImageSliceBottom - style.backgroundImageSliceTop);
                }

                if (slice == null) {
                    if (imageRect.width == imageInfo.width && imageRect.height == imageInfo.height) {
                        background.push('url(${imageInfo.data.src})');
                        if (style.backgroundImageRepeat == null) {
                            css.backgroundRepeat = "no-repeat";
                        } else if (style.backgroundImageRepeat == "repeat") {
                            css.backgroundRepeat = "repeat";
                        } else if (style.backgroundImageRepeat == "stretch") {
                            css.backgroundRepeat = "no-repeat";
                            css.backgroundSize = '${HtmlUtils.px(width)} ${HtmlUtils.px(height)}';
                        }
                    } else {
                        var canvas:CanvasElement = Browser.document.createCanvasElement();
                        canvas.width = cast width;
                        canvas.height = cast height;
                        var ctx:CanvasRenderingContext2D = canvas.getContext2d();
                        paintBitmap(ctx, cast imageInfo.data, imageRect, new Rectangle(0, 0, width, height));
                        var data = canvas.toDataURL();
                        background.push('url(${data})');
                    }
                } else {
                    var rects:Slice9Rects = Slice9.buildRects(width, height, imageRect.width, imageRect.height, slice);
                    var srcRects:Array<Rectangle> = rects.src;
                    var dstRects:Array<Rectangle> = rects.dst;

                    var canvas:CanvasElement = Browser.document.createCanvasElement();
                    canvas.width = cast width;
                    canvas.height = cast height;
                    var ctx:CanvasRenderingContext2D = canvas.getContext2d();
                    ctx.imageSmoothingEnabled = false;

                    for (i in 0...srcRects.length) {
                        var srcRect = new Rectangle(srcRects[i].left + imageRect.left,
                                                    srcRects[i].top + imageRect.top,
                                                    srcRects[i].width,
                                                    srcRects[i].height);
                        var dstRect = dstRects[i];
                        paintBitmap(ctx, cast imageInfo.data, srcRect, dstRect);
                    }

                    var data = canvas.toDataURL();
                    background.push('url(${data})');
                }
                
                background.reverse();
                css.background = background.join(",");
            });
        } else {
            css.background = background[0];
        }
    }

    private static function paintBitmap(ctx:CanvasRenderingContext2D, img:Image, srcRect:Rectangle, dstRect:Rectangle) {
        ctx.drawImage(img, srcRect.left, srcRect.top, srcRect.width, srcRect.height, dstRect.left, dstRect.top, dstRect.width, dstRect.height);
    }
}