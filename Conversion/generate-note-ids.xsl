<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:pm="http://demo.dataformat.com/local/pm"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    version="2.0">
    
    <!-- template to generate ids for notes -->
    
    <xsl:output method="xml" encoding="utf-8"/>
    
    <xsl:template match="/" exclude-result-prefixes="#all">
      <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text() | comment() | processing-instruction()">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="@*" exclude-result-prefixes="#all">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="@xml:id">
        <xsl:attribute name="xml:id" select="generate-id()"/>
    </xsl:template>
    
    
</xsl:stylesheet>