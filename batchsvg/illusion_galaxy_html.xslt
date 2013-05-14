<xsl:stylesheet version="1.1"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:math="http://exslt.org/math"
                xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:param name="level-width"/>
    <xsl:param name="level-height"/>
    <xsl:param name="level-scale"/>

    <xsl:param name="target"/>
    <xsl:param name="style"/>

    <xsl:param name="planet-stroke-width">1</xsl:param>

    <xsl:output method="html"/>

    <xsl:include href="illusion_svg.xslt"/>
    <xsl:param name="interactivity"/>


    <xsl:template match="/">
        <html>
            <head>
                <title>Galactic Map</title>
                <script type="text/javascript" src="../js/util.js"><xsl:comment/></script>
                <script type="text/javascript">
                    var attach = function() {
                        var svg = document.getElementById("svg");
                        svg.onmousedown = function(evt) {
                            var x = (evt.clientX - svg.offsetLeft - <xsl:value-of select="$level-width div 2"/>) / <xsl:value-of select="$level-scale"/>;
                            var y = (evt.clientY - svg.offsetTop - <xsl:value-of select="$level-height div 2"/>) / <xsl:value-of select="$level-scale"/>;
                            var dx;
                            var dy;
                            var p;
                            <xsl:for-each select="batchsvg/valueset[@name='level']/value[@name != 'galaxy']">
                                <xsl:variable name="x-position" select="property[@name='planet-x']"/>
                                <xsl:variable name="y-position" select="property[@name='planet-y']"/>
                                <xsl:variable name="planet-size" select="property[@name='planet-size']"/>
                                <xsl:variable name="url"><xsl:value-of select="$target"/>_<xsl:value-of select="$style"/>_<xsl:value-of
                                        select="$interactivity"/>_<xsl:value-of select="@name"/>.html</xsl:variable>
                                dx = x - <xsl:value-of select="$x-position"/>;
                                dy = y - <xsl:value-of select="$y-position"/>;
                                p = <xsl:value-of select="$planet-size"/>;
                                if( util.lessThan(dx * dx + dy * dy, p * p) ) {
                                    window.location = '<xsl:value-of select="$url"/>';
                                }
                            </xsl:for-each>
                            return false;
                        }
                        svg.onmouseup = function(evt) {
                            return false;
                        }
                    }
                </script>
            </head>
            <body onload="attach()" bgcolor="black">
                <center>
                    <xsl:apply-templates select="batchsvg"/>
                </center>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="batchsvg">
        <svg id="svg" width="{$level-width}" height="{$level-height}" viewBox="{-$level-width div 2} {-$level-height div 2} {$level-width} {$level-height}">
            <g>
                <rect x="{-$level-width div 2}" y="{-$level-height div 2}" width="{$level-width}" height="{$level-height}" fill="black"/>
                <g transform="scale({$level-scale})">
                    <!--
                    <xsl:apply-templates select="valueset[@name='level']/value[@name != 'galaxy']" mode="lines"/>
                    -->
                    <xsl:apply-templates select="valueset[@name='level']/value[@name != 'galaxy']" mode="planets"/>
                </g>
            </g>
        </svg>
    </xsl:template>

    <xsl:template match="value" mode="lines">
        <xsl:variable name="x-position" select="property[@name='planet-x']"/>
        <xsl:variable name="y-position" select="property[@name='planet-y']"/>
        <g>
            <xsl:for-each select="dependency">
                <xsl:variable name="dep-name" select="@planet"/>
                <xsl:variable name="dep-x" select="../../value[@name=$dep-name]/property[@name='planet-x']"/>
                <xsl:variable name="dep-y" select="../../value[@name=$dep-name]/property[@name='planet-y']"/>
                <line x1="{$x-position}" y1="{$y-position}" x2="{$dep-x}" y2="{$dep-y}">
                    <xsl:attribute name="stroke">
                        <xsl:choose>
                            <xsl:when test="@requires = 'points-bronze'">
                                <xsl:value-of select="$player-color-bronze"/>
                            </xsl:when>
                            <xsl:when test="@requires = 'points-silver'">
                                <xsl:value-of select="$player-color-silver"/>
                            </xsl:when>
                            <xsl:when test="@requires = 'points-gold'">
                                <xsl:value-of select="$player-color-gold"/>
                            </xsl:when>
                            <xsl:otherwise>black</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </line>
            </xsl:for-each>
        </g>
    </xsl:template>

    <xsl:template match="value" mode="planets">
        <xsl:variable name="x-position" select="property[@name='planet-x']"/>
        <xsl:variable name="y-position" select="property[@name='planet-y']"/>
        <xsl:variable name="planet-size" select="property[@name='planet-size']"/>
        <xsl:variable name="planet-color" select="property[@name='planet-color']"/>
        <xsl:variable name="planet-name" select="property[@name='level-name']"/>
        <g>
            <defs>
                <radialGradient id="grad-{@name}" gradientUnits="userSpaceOnUse"
                                cx="{$x-position}" cy="{$y-position}" r="{$planet-size * 1.5}">
                    <stop offset="0%" stop-color="{$planet-color}"  stop-opacity="0" />
                    <stop offset="60%" stop-color="{$planet-color}"  stop-opacity="0" />
                    <stop offset="66.66%" stop-color="{$planet-color}"  stop-opacity="0.8" />
                    <stop offset="100%" stop-color="{$planet-color}" stop-opacity="0" />
                </radialGradient>
                <radialGradient id="depth-{@name}" gradientUnits="userSpaceOnUse"
                                cx="{$x-position + $planet-size div 3}" cy="{$y-position - $planet-size div 3}" r="{$planet-size * 1.5}">

                    <stop offset="0%" stop-color="white"  stop-opacity="0.2" />
                    <stop offset="10%" stop-color="white"  stop-opacity="0.15" />
                    <stop offset="20%" stop-color="white"  stop-opacity="0" />
                    <stop offset="30%" stop-color="black"  stop-opacity="0" />
                    <stop offset="100%" stop-color="black"  stop-opacity="1" />
                </radialGradient>
                <circle id="{@name}" cx="{$x-position}" cy="{$y-position}" r="{$planet-size}" stroke-width="{$planet-stroke-width}" fill="none">

                </circle>
            </defs>

            <clipPath id="clip-{@name}">
                <use xlink:href="#{@name}"/>
            </clipPath>
            <xsl:variable name="xml-file" select="property[@name='xml-file']"/>
            <xsl:variable name="url"><xsl:value-of select="$target"/>_<xsl:value-of select="$style"/>_<xsl:value-of select="@name"/>.html</xsl:variable>

            <g clip-path="url(#clip-{@name})">
                <g transform="translate({$x-position},{$y-position})">
                    <xsl:variable name="scale" select="$planet-size * 30 div $level-height"/>
                    <!--
                    <g transform="scale({$planet-size div $level-height * 2})">
                    -->
                    <g transform="scale({$scale})">
                        <xsl:apply-templates select="document($xml-file)/level/background">
                            <xsl:with-param name="stroke-width" select="0.2 div $scale"/>
                        </xsl:apply-templates>
                    </g>
                </g>
                <rect x="{-$level-width div 2}" y="{-$level-height div 2}" width="{$level-width}" height="{$level-height}" fill="url(#depth-{@name})"/>
            </g>

            <rect x="{-$level-width div 2}" y="{-$level-height div 2}" width="{$level-width}" height="{$level-height}" fill="url(#grad-{@name})">
                <animate attributeType="XML" values="1; 0.8; 1"  dur="{$planet-size}"
                                    additive="replace" fill="freeze" attributeName="opacity" repeatCount="indefinite"/>

            </rect>
            <text x="{$x-position}" y="{$y-position + $planet-size * 1.2 + 2}" fill="#44ff44" text-anchor="middle" alignment-baseline="top" font-family="Arial" font-size="1.5" onmousedown="window.location = '{$url}';return false;'"><xsl:value-of
                    select="$planet-name"/></text>
        </g>
    </xsl:template>

</xsl:stylesheet>