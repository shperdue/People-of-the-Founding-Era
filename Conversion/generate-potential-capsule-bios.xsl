<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:pm="http://demo.dataformat.com/local/pm"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    version="2.0">

    <!--  
         template to generate capsule bios in DARMA xml from TJ MB notes (with persNames)
    -->
    <!-- import xsl to generate html from notes content -->
    
    <!-- <xsl:import href="http://ptjrs2.dataformat.com/local/ptjrs_tei_normal.xsl"/> -->

    <!-- load in prebuilt list of note refs with dates of the MB entries they appear in.
         @targets are the note ids.
    -->
    <xsl:variable name="refs-by-date" select="doc('out/refs-by-date.xml')"/>

    <xsl:output method="xml" encoding="utf-8"/>

    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:result-document href="out/capsule-bios.xml" method="xml" encoding="utf-8" indent="yes">
            <Data xmlns="http://www.dataformat.com/darma"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.dataformat.com/darma http://www.dataformat.com/local/darma_data_V2.xsd">
                <Header>
                    <Collections>
                        <Collection name="Papers of Thomas Jefferson" xml:id="c20"/>
                    </Collections>
                </Header>
                <xsl:for-each
                    select="tei:teiCorpus/tei:TEI/tei:text/tei:body/descendant::tei:note[descendant::tei:persName]">
                    <xsl:variable name="note-content" select="."/>
                    <xsl:variable name="note-id" select="@xml:id"/>
                    <xsl:variable name="year" select="ancestor::tei:div2/@n" as="xs:integer"/>
                    <xsl:variable name="volume-number">
                        <xsl:choose>
                            <xsl:when test="$year &lt;= 1790">I</xsl:when>
                            <xsl:otherwise>II</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="date" select="$refs-by-date/*:refs/*:ref[@target = $note-id]/@when"/>
                    <xsl:for-each select="descendant::tei:persName">
                        <xsl:variable name="bio-id" select="concat($note-id, '_', (count(preceding-sibling::tei:persName)+1))"/>
                        <Object collectionID="c20">
                            <Name>
                                <xsl:value-of select="normalize-space(.)"/>
                            </Name>
                            <xsl:if test="following-sibling::text()[1][matches(.,'^\s*\([^\)]+\)')]">
                                <xsl:processing-instruction name="possible-lifedates" select="replace(normalize-space(substring-before(following-sibling::text()[1],')')),'\(','')"/>
                            </xsl:if>
                            <Metadata>
                                <Datum fieldID="f4" fieldName="biographies.Bio" status="new">
                                    <html xmlns="http://www.w3.org/1999/xhtml">
                                        <head>
                                            <title>Biography</title>
                                            <link
                                                href="http://dcdarma.dataformat.com/Resources/RadEditorConfigs/CSS/XHTML_PFE_II.css"
                                                type="text/css" rel="stylesheet"/>
                                        </head>
                                        <body>
                                            <xsl:apply-templates select="ancestor::tei:note" exclude-result-prefixes="#all"/>
                                        </body>
                                    </html>
                                </Datum>
                            <Datum fieldID="f7" fieldName="biographies.Cite" status="new">
                                <html xmlns="http://www.w3.org/1999/xhtml">
                                    <head>
                                        <title>Citation</title>
                                        <link
                                            href="http://dcdarma.dataformat.com/Resources/RadEditorConfigs/CSS/XHTML_PFE_II.css"
                                            type="text/css" rel="stylesheet"/>
                                    </head>
                                    <body>
                                        <p><em>Jefferson’s Memorandum Books: Accounts, with Legal Records and Miscellany, 1767–1826</em>, 1997, <em>The Papers of Thomas Jefferson, Second Series.</em> Volume <xsl:value-of select="$volume-number"/><xsl:choose><xsl:when test="matches(string($date),'^\d\d\d\d-\d\d-\d\d$')">, <xsl:value-of select="format-date($date, '[MNn] [D], [Y]')"/></xsl:when><xsl:otherwise><xsl:value-of select="$year"/></xsl:otherwise></xsl:choose>.</p>
                                    </body>
                                </html>
                            </Datum>
                            <Datum fieldID="f91" fieldName="Project Specific ID" status="new">
                                <Value>
                                    <xsl:value-of select="$bio-id"/>
                                </Value>
                            </Datum>
                            </Metadata>
                        </Object>
                    </xsl:for-each>
                </xsl:for-each>
            </Data>
        </xsl:result-document>
    </xsl:template>
    
    
    <!-- cleaner to build templates for note content than import from ptjrs2 -->
    <xsl:template match="tei:note | tei:bibl" exclude-result-prefixes="#all">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:p" exclude-result-prefixes="#all">
        <p xmlns="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend = 'italic']" exclude-result-prefixes="#all">
        <em xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates/></em>
    </xsl:template>    
    
    <xsl:template match="tei:hi[@rend = 'small-caps']" exclude-result-prefixes="#all">
        <span xmlns="http://www.w3.org/1999/xhtml" style="font-variant:small-caps;"><xsl:apply-templates/></span>
    </xsl:template>    
    
    <xsl:template match="tei:hi[@rend = 'superscript']" exclude-result-prefixes="#all">
        <span xmlns="http://www.w3.org/1999/xhtml" style="font-size:66%;vertical-align:super;"><xsl:apply-templates/></span>
    </xsl:template>    
    
    <xsl:template match="tei:hi[@rend = 'greek']" exclude-result-prefixes="#all">
        <span xmlns="http://www.w3.org/1999/xhtml" class="greek"><xsl:apply-templates/></span>
    </xsl:template>    
    
    <xsl:template match="tei:title" exclude-result-prefixes="#all">
        <em xmlns="http://www.w3.org/1999/xhtml" class="title"><xsl:apply-templates/></em>
    </xsl:template>
    
    <xsl:template match="tei:ref" exclude-result-prefixes="#all">
        <span xmlns="http://www.w3.org/1999/xhtml" class="ref"><xsl:apply-templates/></span>
    </xsl:template>
    
    <xsl:template match="tei:persName" exclude-result-prefixes="#all">
        <span xmlns="http://www.w3.org/1999/xhtml" class="persName"><xsl:apply-templates/></span>
    </xsl:template>
    
</xsl:stylesheet>
