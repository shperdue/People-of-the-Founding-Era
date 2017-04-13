<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="saxon"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:pm="http://demo.dataformat.com/local/pm"
    xmlns:ptjrs="http://ptjrs.dataformat.com/ptjrs"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:saxon="http://saxon.sf.net/" version="3.0">

    <!-- 
    build an index of dates for notes (by ref placement) to be used in building cites for PFE capsule bios
    -->

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:result-document method="xml" encoding="utf-8" indent="yes" href="out/refs-by-date.xml">
            <refs>
                <xsl:for-each select="/tei:teiCorpus/tei:TEI/tei:text/tei:body/descendant::tei:ref">
                    <xsl:variable name="date" select="ancestor::tei:tr[not(@role = 'etbt')][@n]/@n"/>
                    <ref target="{@target}" when="{$date}"/>
                </xsl:for-each>
            </refs>
        </xsl:result-document>
    </xsl:template>




</xsl:stylesheet>
