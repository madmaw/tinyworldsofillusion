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

    <xsl:param name="player-radius-outer">2.4</xsl:param>
    <xsl:param name="player-radius-inner">1.4</xsl:param>
    <xsl:param name="player-turret-length">3</xsl:param>
    <xsl:param name="player-turret-width">0.5</xsl:param>
    <xsl:param name="player-stroke-width">0.4</xsl:param>

    <xsl:param name="player-missile-speed">2</xsl:param>

    <xsl:param name="interactivity"/>

    <xsl:param name="pi" select="math:constant('PI',10)"/>
    <xsl:param name="degrees-to-radians-mult" select="$pi div 180"/>

    <xsl:template match="entity[@type='player']">
        <g>
            <xsl:choose>
                <xsl:when test="$interactivity = 'none'">
                    <circle r="{$player-stroke-width}" fill="black"/>
                </xsl:when>
                <xsl:otherwise>
                    <defs>
                        <path id="player-outline" d="
                            M {$player-turret-length},{-$player-turret-width div 1.9}
                            L {$player-turret-length},{$player-turret-width div 1.9}
                            L {$player-radius-outer},{$player-turret-width div 2}
                            A {$player-radius-outer},{$player-radius-outer} 0 1,1 {$player-radius-outer},{-$player-turret-width div 2}
                            z">
                            <xsl:if test="$interactivity = 'spin'">
                                <xsl:apply-templates select="." mode="rotation"/>
                            </xsl:if>
                        </path>
                        <!--
                        <circle id="player-missile" cx="0" cy="0" r="{$player-turret-width * $level-scale}" fill="none" stroke="none"/>
                        -->
                        <rect id="player-missile" x="-{$player-turret-width}" y="-{$player-turret-width div 2}" width="{$player-turret-width * 2}" height="{$player-turret-width}" fill="white" stroke="{attribute[@name='stroke']/@value}" stroke-width="{$player-stroke-width}"/>
                    </defs>
                    <clipPath id="outline-clip">
                        <use xlink:href="#player-outline"/>
                    </clipPath>
                    <g id="color-wheels">
                        <xsl:apply-templates select="color-wheel">
                            <xsl:with-param name="clip-path-id">outline-clip</xsl:with-param>
                            <xsl:with-param name="r" select="$player-turret-length + $player-turret-width"/>
                        </xsl:apply-templates>
                    </g>
                    <use xlink:href="#player-outline" stroke-width="{$player-stroke-width}" fill="none">
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">stroke</xsl:with-param>
                        </xsl:apply-templates>
                    </use>
                    <circle cx="0" cy="0" r="{$player-radius-inner}" stroke-width="{$player-stroke-width}" fill="{$player-color-default}">
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">stroke</xsl:with-param>
                        </xsl:apply-templates>
                        <!-- TODO specify some animations (activated by Javascript) for multipliers -->
                        <animate id="achievement-0" attributeType="XML" from="{$player-color-default}" to="{$player-color-bronze}" dur="1"
                                            additive="replace" fill="freeze" begin="indefinite" attributeName="fill"/>
                        <animate id="achievement-1" attributeType="XML" from="{$player-color-bronze}" to="{$player-color-silver}" dur="1"
                                            additive="replace" fill="freeze" begin="indefinite" attributeName="fill"/>
                        <animate id="achievement-2" attributeType="XML" from="{$player-color-silver}" to="{$player-color-gold}" dur="1"
                                            additive="replace" fill="freeze" begin="indefinite" attributeName="fill"/>

                        <!--
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">fill-inner</xsl:with-param>
                            <xsl:with-param name="svg-attribute-name">fill</xsl:with-param>
                        </xsl:apply-templates>
                        -->
                    </circle>
                    <text id="player-multiplier" x="0" y="0" fill="{$player-color-multiplier}" text-anchor="middle" alignment-baseline="central" font-family="Arial" font-weight="bold" font-size="{$player-radius-inner}">1</text>
                    <g id="bonuses">
                        <xsl:for-each select="bonus">
                            <g opacity="0">
                                <clipPath id="bonus-{position()}">
                                    <rect x="{-$player-radius-inner}" width="{$player-radius-inner * 2}" y="{-$player-radius-inner}" height="{$player-radius-inner * 2}">
                                        <animate attributeType="XML" from="0" to="{-$player-radius-inner}" dur="0.5"
                                                            additive="replace" fill="freeze" begin="{@begin}s" attributeName="y"/>
                                        <animate attributeType="XML" from="0" to="{$player-radius-inner * 2}" dur="0.5"
                                                            additive="replace" fill="freeze" begin="{@begin}s" attributeName="height"/>
                                        <animate attributeType="XML" from="{-$player-radius-inner}" to="0" dur="0.5"
                                                            additive="replace" fill="freeze" begin="{@begin + @dur - 0.5}s" attributeName="y" name="close"/>
                                        <animate attributeType="XML" from="{$player-radius-inner * 2}" to="0" dur="0.5"
                                                            additive="replace" fill="freeze" begin="{@begin + @dur - 0.5}s" attributeName="height" name="close"/>
                                    </rect>
                                </clipPath>
                                <g clip-path="url(#bonus-{position()})">
                                    <circle cx="0" cy="0" r="{$player-radius-inner}" fill="red" stroke="none"/>
                                    <circle cx="0" cy="0" r="{$player-radius-inner div 2}" fill="white" stroke="none">
                                        <animateTransform attributeName="transform" attributeType="XML"
                                                            type="scale" values="1; 1.2; 1" dur="1s"
                                                            additive="replace" fill="freeze" begin="{@begin}s" repeatCount="{@dur}"/>
                                        <!--
                                        <animateMotion dur="0.2" begin="{@begin + 0.3}" path="M 0,0 L{-$player-radius-inner div 2},0"/>
                                        <animateMotion dur="0.5" begin="{@begin + @dur div 2 - 0.25}" path="M{-$player-radius-inner div 2},0 L{$player-radius-inner div 2},0 "/>
                                        <animateMotion dur="0.2" begin="{@begin + @dur - 0.5}" path="M {$player-radius-inner div 2},0 0,0"/>
                                        -->
                                    </circle>
                                </g>
                                <animate attributeType="XML" from="0" to="1" dur="0.5s"
                                                    additive="replace" fill="freeze" begin="{@begin}s" attributeName="opacity"/>
                                <animate attributeType="XML" from="1" to="0" dur="0.5s"
                                                    additive="replace" fill="freeze" begin="{@begin + @dur - 0.5}s" attributeName="opacity" name="close"/>
                            </g>
                        </xsl:for-each>
                    </g>

                </xsl:otherwise>
            </xsl:choose>

        </g>
    </xsl:template>


    <xsl:template match="color-wheel">
        <xsl:param name="clip-path-id"/>
        <xsl:param name="r"/>
        <xsl:param name="index">1</xsl:param>
        <xsl:param name="previous-angle" select="@angle-offset"/>
        <xsl:variable name="color" select="color[$index]"/>
        <xsl:variable name="to-angle" select="$color/@to-angle + @angle-offset"/>
        <path clip-path="url(#{$clip-path-id})" d="
            M 0,0
            L {math:cos($previous-angle * $degrees-to-radians-mult) * $r},{math:sin($previous-angle * $degrees-to-radians-mult) * $r}
            A {$r},{$r} 1 1,1 {math:cos($to-angle * $degrees-to-radians-mult) * $r},{math:sin($to-angle * $degrees-to-radians-mult) * $r}
            z" stroke="none" fill="{$color/@value}" fromangle="{$previous-angle}" toangle="{$to-angle}">
            <xsl:apply-templates select="." mode="rotation"/>
        </path>
        <xsl:if test="count(color) > $index">
            <xsl:apply-templates select=".">
                <xsl:with-param name="clip-path-id" select="$clip-path-id"/>
                <xsl:with-param name="index" select="$index + 1"/>
                <xsl:with-param name="previous-angle" select="$to-angle"/>
                <xsl:with-param name="r" select="$r"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="transform">
        <xsl:if test="count(transform)>0">
            <xsl:attribute name="transform">
                <xsl:for-each select="transform">
                    <xsl:value-of select="@value"/>
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="rotation">
        <xsl:param name="index">1</xsl:param>
        <xsl:param name="rotations" select="rotation"/>
        <xsl:param name="rotation" select="$rotations[$index]"/>
        <xsl:param name="default-start-time">0</xsl:param>
        <xsl:param name="start-time">
            <xsl:choose>
                <xsl:when test="$rotation/@start">
                    <xsl:value-of select="$rotation/@start"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$default-start-time"/></xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:if test="count($rotations) >= $index">
            <animateTransform attributeName="transform" attributeType="XML"
                                type="rotate" from="0" dur="{$rotation/@cycle-time}s"
                                additive="replace" fill="freeze" begin="{$start-time}s" name="player-rotation">
                <xsl:attribute name="to">
                    <xsl:choose>
                        <xsl:when test="$rotation/@ccw = 'true'">-360</xsl:when>
                        <xsl:otherwise>360</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$rotation/@end">
                        <xsl:attribute name="end">
                            <xsl:value-of select="$rotation/@end"/>
                        </xsl:attribute>
                        <xsl:attribute name="repeatCount">
                            <xsl:value-of select="$rotation/@end div $rotation/@cycle-time"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="repeatCount">indefinite</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </animateTransform>
            <xsl:apply-templates select="." mode="rotation">
                <xsl:with-param name="index" select="$index + 1"/>
                <xsl:with-param name="default-start-time" select="$rotation/@end"/>
                <xsl:with-param name="rotations" select="$rotations"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <xsl:template match="entity" mode="position">
        <xsl:param name="index">1</xsl:param>
        <xsl:param name="start-time">0</xsl:param>
        <xsl:param name="positions" select="position"/>
        <xsl:param name="position" select="$positions[$index]"/>
        <xsl:param name="previous-x" select="$position/@x"/>
        <xsl:param name="previous-y" select="$position/@y"/>
        <xsl:if test="count($positions) >= $index">
            <xsl:variable name="duration">
                <xsl:choose>
                    <xsl:when test="$position/@dur">
                        <xsl:value-of select="$position/@dur"/>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <animateMotion dur="{$duration}s" begin="{$start-time}s">
                <xsl:attribute name="path">
                    M <xsl:value-of select="$previous-x"/>,<xsl:value-of select="$previous-y"/> L <xsl:value-of select="$position/@x"/>,<xsl:value-of select="$position/@y"/>
                </xsl:attribute>
            </animateMotion>
            <xsl:apply-templates select="." mode="position">
                <xsl:with-param name="index" select="$index + 1"/>
                <xsl:with-param name="start-time" select="$position/@end"/>
                <xsl:with-param name="positions" select="$positions"/>
                <xsl:with-param name="previous-x" select="$position/@x"/>
                <xsl:with-param name="previous-y" select="$position/@y"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>


    <xsl:template match="*" mode="attributes">
        <xsl:param name="source-attribute-name"/>
        <xsl:param name="svg-attribute-name" select="$source-attribute-name"/>
        <xsl:attribute name="{$svg-attribute-name}">
            <xsl:apply-templates select="." mode="first-attribute">
                <xsl:with-param name="source-attribute-name" select="$source-attribute-name"/>
                <xsl:with-param name="svg-attribute-name" select="svg-attribute-name"/>
            </xsl:apply-templates>
        </xsl:attribute>
        <xsl:apply-templates select="." mode="animate-attributes">
            <xsl:with-param name="source-attribute-name" select="$source-attribute-name"/>
            <xsl:with-param name="svg-attribute-name" select="$svg-attribute-name"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="first-attribute">
        <xsl:param name="source-attribute-name"/>
        <xsl:variable name="entity-attribute-value" select="attribute[@name=$source-attribute-name and string-length(@begin)=0]/@value"/>
        <xsl:choose>
            <xsl:when test="string-length($entity-attribute-value)>0">
                <xsl:value-of select="$entity-attribute-value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="entity-type" select="@type"/>
                <xsl:value-of select="/level/globals/attribute[@entity-type=$entity-type and @name=$source-attribute-name]/@value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="animate-attributes">
        <xsl:param name="index">1</xsl:param>
        <xsl:param name="start-time">0</xsl:param>
        <xsl:param name="source-attribute-name"/>
        <xsl:param name="svg-attribute-name"/>
        <xsl:param name="previous-value">
            <xsl:apply-templates select="." mode="first-attribute">
                <xsl:with-param name="source-attribute-name" select="$source-attribute-name"/>
            </xsl:apply-templates>
        </xsl:param>
        <xsl:param name="attributes" select="attribute[@name=$source-attribute-name]"/>
        <xsl:if test="count($attributes) >= $index">
            <xsl:variable name="attribute" select="$attributes[$index]"/>
            <xsl:variable name="duration">
                <xsl:choose>
                    <xsl:when test="$attribute/@dur">
                        <xsl:value-of select="$attribute/@dur"/>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$duration > 0">
                    <animate attributeType="XML" from="{$previous-value}" to="{$attribute/@value}" dur="{$duration}"
                                        additive="replace" fill="freeze" begin="{$start-time}" attributeName="{$svg-attribute-name}"/>
                </xsl:when>
                <xsl:otherwise>
                    <set attributeType="XML" to="{$attribute/@value}"
                                                            additive="replace" fill="freeze" begin="{$start-time}s" attributeName="{$svg-attribute-name}"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="." mode="animate-attributes">
                <xsl:with-param name="index" select="$index + 1"/>
                <xsl:with-param name="start-time" select="$attribute/@end"/>
                <xsl:with-param name="attributes" select="$attributes"/>
                <xsl:with-param name="source-attribute-name" select="$source-attribute-name"/>
                <xsl:with-param name="svg-attribute-name" select="$svg-attribute-name"/>
                <xsl:with-param name="previous-value" select="$attribute/@value"/>
            </xsl:apply-templates>

        </xsl:if>
    </xsl:template>

    <xsl:template match="attribute">

    </xsl:template>

    <xsl:template match="background[@type='solid']">
        <rect x="{-$level-width div 2}" y="{-$level-height div 2}" width="{$level-width}" height="{$level-height}">
            <xsl:apply-templates select="." mode="attributes">
                <xsl:with-param name="source-attribute-name">fill</xsl:with-param>
            </xsl:apply-templates>
        </rect>
    </xsl:template>

    <xsl:template match="background[@type='grid']">
        <xsl:param name="stroke-width"/>
        <g>
            <xsl:apply-templates select="." mode="transform"/>
            <g>
                <xsl:apply-templates select="." mode="rotation"/>

                <xsl:variable name="x1" select="-@cols * @spacing div 2"/>
                <xsl:variable name="x2" select="$x1 + @cols * @spacing"/>
                <xsl:variable name="y1" select="-@rows * @spacing div 2"/>
                <xsl:variable name="y2" select="$y1 + @rows * @spacing"/>
                <xsl:apply-templates select="." mode="lines">
                    <xsl:with-param name="x1" select="$x1"/>
                    <xsl:with-param name="y1" select="$y1"/>
                    <xsl:with-param name="x2" select="$x2"/>
                    <xsl:with-param name="y2" select="$y1"/>
                    <xsl:with-param name="dy" select="@spacing"/>
                    <xsl:with-param name="dx">0</xsl:with-param>
                    <xsl:with-param name="stroke-width" select="$stroke-width"/>
                    <xsl:with-param name="num-lines" select="@rows + 1"/>

                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="lines">
                    <xsl:with-param name="x1" select="$x1"/>
                    <xsl:with-param name="y1" select="$y1"/>
                    <xsl:with-param name="x2" select="$x1"/>
                    <xsl:with-param name="y2" select="$y2"/>
                    <xsl:with-param name="dx" select="@spacing"/>
                    <xsl:with-param name="dy">0</xsl:with-param>
                    <xsl:with-param name="stroke-width" select="$stroke-width"/>
                    <xsl:with-param name="num-lines" select="@cols + 1"/>
                </xsl:apply-templates>

                <xsl:if test="@r">
                    <xsl:apply-templates select="." mode="dots">
                        <xsl:with-param name="rows" select="@rows"/>
                        <xsl:with-param name="cols" select="@cols"/>
                        <xsl:with-param name="x" select="$x1"/>
                        <xsl:with-param name="y" select="$y1"/>
                        <xsl:with-param name="r" select="@r"/>
                        <xsl:with-param name="dx" select="@spacing"/>
                        <xsl:with-param name="dy" select="@spacing"/>
                    </xsl:apply-templates>
                </xsl:if>
            </g>
        </g>
    </xsl:template>

    <xsl:template match="*" mode="dots">
        <xsl:param name="row">0</xsl:param>
        <xsl:param name="col">0</xsl:param>
        <xsl:param name="rows"/>
        <xsl:param name="cols"/>
        <xsl:param name="x"/>
        <xsl:param name="ix" select="$x"/>
        <xsl:param name="y"/>
        <xsl:param name="dx"/>
        <xsl:param name="dy"/>
        <xsl:param name="r"/>


        <xsl:if test="$rows >= $row">
            <xsl:choose>
                <xsl:when test="$cols >= $col">
                    <circle cx="{$x}" cy="{$y}" r="{$r}" stroke="none">
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">fill</xsl:with-param>
                        </xsl:apply-templates>
                    </circle>
                    <xsl:apply-templates select="." mode="dots">
                        <xsl:with-param name="row" select="$row"/>
                        <xsl:with-param name="col" select="$col + 1"/>
                        <xsl:with-param name="rows" select="$rows"/>
                        <xsl:with-param name="cols" select="$cols"/>
                        <xsl:with-param name="x" select="$x + $dx"/>
                        <xsl:with-param name="ix" select="$ix"/>
                        <xsl:with-param name="dx" select="$dx"/>
                        <xsl:with-param name="dy" select="$dy"/>
                        <xsl:with-param name="y" select="$y"/>
                        <xsl:with-param name="r" select="$r"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="dots">
                        <xsl:with-param name="row" select="$row + 1"/>
                        <xsl:with-param name="col">0</xsl:with-param>
                        <xsl:with-param name="rows" select="$rows"/>
                        <xsl:with-param name="cols" select="$cols"/>
                        <xsl:with-param name="x" select="$ix"/>
                        <xsl:with-param name="ix" select="$ix"/>
                        <xsl:with-param name="y" select="$y + $dy"/>
                        <xsl:with-param name="dx" select="$dx"/>
                        <xsl:with-param name="dy" select="$dy"/>
                        <xsl:with-param name="r" select="$r"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

    </xsl:template>

    <xsl:template match="*" mode="lines">
        <xsl:param name="x1"/>
        <xsl:param name="y1"/>
        <xsl:param name="x2" select="$x1"/>
        <xsl:param name="y2" select="$y1"/>
        <xsl:param name="dx"/>
        <xsl:param name="dy"/>
        <xsl:param name="line">0</xsl:param>
        <xsl:param name="num-lines"/>
        <xsl:param name="stroke-width"/>

        <xsl:if test="$num-lines > $line">
            <line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2}">
                <xsl:if test="$stroke-width">
                    <xsl:attribute name="stroke-width">
                        <xsl:value-of select="$stroke-width"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="." mode="attributes">
                    <xsl:with-param name="source-attribute-name">stroke</xsl:with-param>
                </xsl:apply-templates>
                <xsl:if test="string-length($stroke-width) = 0">
                    <xsl:apply-templates select="." mode="attributes">
                        <xsl:with-param name="source-attribute-name">stroke-width</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:if>
            </line>
            <xsl:apply-templates select="." mode="lines">
                <xsl:with-param name="x1" select="$x1 + $dx"/>
                <xsl:with-param name="y1" select="$y1 + $dy"/>
                <xsl:with-param name="x2" select="$x2 + $dx"/>
                <xsl:with-param name="y2" select="$y2 + $dy"/>
                <xsl:with-param name="dx" select="$dx"/>
                <xsl:with-param name="dy" select="$dy"/>
                <xsl:with-param name="line" select="$line + 1"/>
                <xsl:with-param name="num-lines" select="$num-lines"/>
                <xsl:with-param name="stroke-width" select="$stroke-width"/>
            </xsl:apply-templates>
        </xsl:if>

    </xsl:template>

    <xsl:template match="entity[@type='dot']">
        <g>

            <xsl:apply-templates select="." mode="transform"/>
            <xsl:apply-templates select="." mode="rotation"/>
            <g>
                <xsl:if test="@style='graded'">
                    <xsl:attribute name="opacity">0.3</xsl:attribute>
                </xsl:if>
                <circle name="color-tester">
                    <xsl:apply-templates select="." mode="attributes">
                        <xsl:with-param name="source-attribute-name">r</xsl:with-param>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="." mode="attributes">
                        <xsl:with-param name="source-attribute-name">fill</xsl:with-param>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="." mode="attributes">
                        <xsl:with-param name="source-attribute-name">opacity</xsl:with-param>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="." mode="attributes">
                        <xsl:with-param name="source-attribute-name">cx</xsl:with-param>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="." mode="attributes">
                        <xsl:with-param name="source-attribute-name">cy</xsl:with-param>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="." mode="position"/>
                </circle>
            </g>
            <xsl:if test="@style='graded'">
                <g>
                    <circle transform="scale(0.4)">
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">r</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">fill</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">opacity</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">cx</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">cy</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="position"/>
                    </circle>
                </g>
                <g>
                    <xsl:if test="@style='graded'">
                        <xsl:attribute name="opacity">0.7</xsl:attribute>
                    </xsl:if>
                    <circle transform="scale(0.7)">
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">r</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">fill</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">opacity</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">cx</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">cy</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="position"/>
                    </circle>
                </g>
                <g>
                    <xsl:if test="@style='graded'">
                        <xsl:attribute name="opacity">0.5</xsl:attribute>
                    </xsl:if>
                    <circle transform="scale(0.85)">
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">r</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">fill</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">opacity</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">cx</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="attributes">
                            <xsl:with-param name="source-attribute-name">cy</xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="." mode="position"/>
                    </circle>
                </g>
            </xsl:if>

        </g>
    </xsl:template>

</xsl:stylesheet>