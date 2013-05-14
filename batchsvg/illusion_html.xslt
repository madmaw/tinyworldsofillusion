<xsl:stylesheet version="1.1"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:math="http://exslt.org/math"
                xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:param name="level-width"/>
    <xsl:param name="level-height"/>
    <xsl:param name="level-scale"/>
    <xsl:param name="level-name"/>

    <xsl:param name="points-bronze"/>
    <xsl:param name="points-silver"/>
    <xsl:param name="points-gold"/>

    <xsl:param name="player-color-default"/>
    <xsl:param name="player-color-bronze"/>
    <xsl:param name="player-color-silver"/>
    <xsl:param name="player-color-gold"/>
    <xsl:param name="player-color-multiplier"/>

    <xsl:param name="background-music"/>

    <xsl:param name="player-missile-speed">2</xsl:param>

    <xsl:param name="pi" select="math:constant('PI',10)"/>
    <xsl:param name="degrees-to-radians-mult" select="$pi div 180"/>
    <xsl:param name="interactivity"/>

    <xsl:output method="html"/>

    <xsl:include href="illusion_svg.xslt"/>

    <xsl:template match="/">
        <html>
            <head>
                <title><xsl:value-of select="$level-name"/></title>
                <script type="text/javascript" src="http://sources.disruptive-innovations.com/jscssp/trunk/cssParser.js"><xsl:comment /></script>
                <script type="text/javascript">
                    var achievementThresholds = [];
                    achievementThresholds[0] = <xsl:value-of select="$points-bronze"/>;
                    achievementThresholds[1] = <xsl:value-of select="$points-silver"/>
                    achievementThresholds[2] = <xsl:value-of select="$points-gold"/>;

                    window.setTimeout(function(){
                        // TODO results screen, fade out
                        window.history.back();
                    }, <xsl:value-of select="level/@time * 1000"/>);
                </script>
                <script type="text/javascript" src="../js/illusion.js"><xsl:comment /></script>

            </head>
            <body
                    onload="illusionInit({-$level-width div 2}, {$level-width div 2}, {-$level-height div 2}, {$level-height div 2}, {$player-radius-inner}, {$player-turret-length}, {$player-missile-speed}, {$level-scale}, achievementThresholds);"
                    bgcolor="{level/background[@type='solid']/attribute[@name='fill']/@value}">
                <center>
                    <xsl:apply-templates select="level"/>
                    <br/>
                    <xsl:if test="$interactivity != 'none'">
                        <xsl:if test="$background-music">
                            <audio id="audio-reset" src="{$background-music}" preload="auto" autoplay="autoplay" controls="controls"><xsl:comment/></audio>
                        </xsl:if>
                    </xsl:if>
                </center>
                <audio id="audio-bonus" src="../audio/bonus.wav" preload="auto"><xsl:comment/></audio>
                <audio id="audio-launch" src="../audio/launch.wav" preload="auto"><xsl:comment/></audio>
                <audio id="audio-explosion" src="../audio/explosion.wav" preload="auto"><xsl:comment/></audio>
                <audio id="audio-reset" src="../audio/reset.wav" preload="auto"><xsl:comment/></audio>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="level">
        <svg width="{$level-width}" height="{$level-height}" viewBox="{-$level-width div 2} {-$level-height div 2} {$level-width} {$level-height}">
            <g transform="scale({$level-scale})">
                <!--
                <rect x="{-$level-width div 2}" y="{-$level-height div 2}" width="{$level-width}" height="{$level-height}" fill="blue"/>
                -->
                <g>
                    <xsl:apply-templates select="background"/>
                </g>
                <g>
                    <xsl:apply-templates select="entity[@type = 'player']"/>
                </g>
                <g id="targets">
                    <xsl:apply-templates select="entity[@type != 'player']"/>
                </g>
                <g id="missiles">

                </g>
            </g>
        </svg>
    </xsl:template>



</xsl:stylesheet>