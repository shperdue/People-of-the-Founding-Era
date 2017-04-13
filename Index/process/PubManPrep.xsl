<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" extension-element-prefixes="saxon" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pm="http://demo.dataformat.com/local/pm">

    <!-- xsl to put title id, sortkey, etc. to prep TJMB index for load to PubMan -->
   

    <xsl:output method="xml" encoding="UTF-8" indent="yes" doctype-system="http://ptjrs2.dataformat.com/local/ObjectCollection.dtd"/>
    
    <xsl:variable name="alpha-section" select="upper-case(replace(substring-after(saxon:system-id(),'Index_'),'\.xml',''))"/>

    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="* | @*" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | *| text() | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <!-- keep comments and PIs						-->
    <xsl:template match="comment() | processing-instruction()">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- things to update -->
    <xsl:template match="Object" exclude-result-prefixes="#all">
        <xsl:variable name="position" select="count(preceding-sibling::Object)"/>
        <xsl:variable name="sortkey" select="concat($alpha-section,'_',format-number($position*100,'00000000'))"/>
        <xsl:variable name="docDesc" select="normalize-space(IndexEntry[1]/MainEntryGrp[1]/Entry[1]/Body[1])"/>
        <Object title="TJMB.III" sortkey="{$sortkey}" docDesc="{$docDesc}">
            <xsl:copy-of select="@entry, @url, @link-target-type, @status"/>
            <xsl:apply-templates select="*"/>
        </Object>
    </xsl:template>


    
    

</xsl:stylesheet>
