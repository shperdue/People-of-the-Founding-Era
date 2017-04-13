<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="saxon"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:pm="http://demo.dataformat.com/local/pm"
    xmlns:ptjrs="http://ptjrs.dataformat.com/ptjrs"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:saxon="http://saxon.sf.net/"  version="3.0">

    <!-- 
     embed footnotes into year documents
    -->


    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    
    <!-- load up the notes -->
    <xsl:variable name="notes-file" select="doc('out/TJ_MB_Footnotes_NamesAndLinksMarked.xml')"/>

    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:processing-instruction name="xml-stylesheet"> type='text/xsl' href='http://ptjrs2.dataformat.com/local/ptjrs_tei_normal.xsl'</xsl:processing-instruction>
        <teiCorpus xmlns="http://www.tei-c.org/ns/1.0" xmlns:pm="http://demo.dataformat.com/local/pm"
            xmlns:ptjrs="http://ptjrs.dataformat.com/ptjrs"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
            xsi:schemaLocation="http://www.tei-c.org/ns/1.0 http://ptjrs2.dataformat.com/local/tei_ptjrs.xsd">
            <xsl:apply-templates select="tei:teiCorpus/tei:TEI"/>
        </teiCorpus>
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
    
    <xsl:template match="tei:div1[position()=last()]" exclude-result-prefixes="#all">
        <xsl:variable name="year" select="ancestor::tei:TEI/@pm:sortkey"/>
        <xsl:copy-of select="."/>
        <div1 xmlns="http://www.tei-c.org/ns/1.0" type="docback" n="{$year}">
            <xsl:copy-of select="$notes-file/tei:teiCorpus/tei:TEI/tei:text/tei:body/tei:div1/tei:div2[@n = $year]/*"/>
        </div1>
    </xsl:template>
 

</xsl:stylesheet>
