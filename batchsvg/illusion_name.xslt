<xsl:stylesheet version="1.1"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text"/>

    <xsl:param name="outputType"/>
    <xsl:param name="target"/>
    <xsl:param name="level"/>
    <xsl:param name="style"/>
    <xsl:param name="interactivity"/>

    <xsl:template match="/">

        <xsl:value-of select="$target"/>_<xsl:value-of select="$style"/>_<xsl:value-of select="$interactivity"/>_<xsl:value-of select="$level"/>.<xsl:value-of select="$outputType"/>
    </xsl:template>

</xsl:stylesheet>