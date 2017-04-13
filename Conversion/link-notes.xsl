<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="saxon"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:pm="http://demo.dataformat.com/local/pm"
    xmlns:ptjrs="http://ptjrs.dataformat.com/ptjrs"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:saxon="http://saxon.sf.net/"  version="3.0">

    <!-- 
     xsl process to link textual note references and notes
    -->

    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    
    <!-- assumption: sortkey is current year (important) -->
    <xsl:variable name="current-year" select="/tei:teiCorpus/tei:TEI/@pm:sortkey"/>
    <xsl:variable name="notes-file" select="doc('out/TJ_MB_Footnotes_NamesAndLinksMarked.xml')"/>
    

    <xsl:variable name="notes">
        <notes xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:for-each select="$notes-file/tei:teiCorpus/tei:TEI/tei:text/tei:body/tei:div1/tei:div2[@n = $current-year]">
            <div2 n="{@n}" type="{@type}">
                <!-- group up the notes into divs of 1 through nn so they are easier to match
                     OR: if the notes don't start with 1 put those in their own group first -->
                <xsl:for-each select="tei:note[@n = '1'] | tei:note[1]">
                    <div3 xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:variable name="next-set-start-note" select="following-sibling::tei:note[@n='1'][1]/@xml:id"/>
                        <xsl:choose>
                            <xsl:when test="following-sibling::tei:note[following-sibling::tei:note[@xml:id = $next-set-start-note]]">
                                <xsl:for-each select=". | following-sibling::tei:note[following-sibling::tei:note[@xml:id = $next-set-start-note]]">
                                    <note n="{concat('n',@n)}" xml:id="{@xml:id}"/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select=". | following-sibling::tei:note">
                                    <note n="{concat('n',@n)}" xml:id="{@xml:id}"/>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div3>
                </xsl:for-each>
            </div2>
        </xsl:for-each>
        </notes>
    </xsl:variable>
    
    
    

    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:processing-instruction name="xml-stylesheet"> type='text/xsl' href='http://ptjrs2.dataformat.com/local/ptjrs_tei_normal.xsl'</xsl:processing-instruction>
        <teiCorpus xmlns="http://www.tei-c.org/ns/1.0" xmlns:pm="http://demo.dataformat.com/local/pm"
            xmlns:ptjrs="http://ptjrs.dataformat.com/ptjrs"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
            xsi:schemaLocation="http://www.tei-c.org/ns/1.0 http://ptjrs2.dataformat.com/local/tei_ptjrs.xsd">
            <xsl:apply-templates select="tei:teiCorpus/tei:TEI"/>
        </teiCorpus>
        <xsl:result-document href="notes-file.xml" method="xml" encoding="utf-8" indent="yes">
            <xsl:copy-of select="$notes"/>
        </xsl:result-document>
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
    
    <xsl:template match="tei:ref[@type = 'textual-note']" exclude-result-prefixes="#all">
        <!-- get a number that will key to the div3 position in $notes -->
        <xsl:variable name="print-number" select="@target"/>
        <!-- set a boolean whether the file begins with note 1 or note -->
        <xsl:variable name="file-starts-with-one-boolean" select="boolean(ancestor::tei:TEI/descendant::tei:ref[1][@target = 'n1'])"/>
        <xsl:message select="$file-starts-with-one-boolean"></xsl:message>
        <xsl:variable name="notes-group-number">
            <xsl:choose>
                <!-- when the file starts with 1 -->
                <xsl:when test="$file-starts-with-one-boolean = true()">
                    <xsl:choose>
                        <!-- when the number is 1, just add 1 -->
                        <xsl:when test="@target = 'n1'">
                            <xsl:value-of select="count(preceding::tei:ref[@target = 'n1']) + 1"/>
                        </xsl:when>
                        <!-- otherwise count the number of group starts -->
                        <xsl:otherwise>
                            <xsl:value-of select="count(preceding::tei:ref[@target = 'n1'])"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- when the files does not start with 1 -->
                <xsl:otherwise>
                    <xsl:choose>
                        <!-- when the ref is the first '1', it's always the start of group 2 -->
                        <xsl:when test="@target = 'n1' and not(preceding::tei:note[@target = 'n1'])">
                            <xsl:value-of select="2"/>
                        </xsl:when>
                        <!-- subsequent '1's are + 2 -->
                        <xsl:when test="@target = 'n1' and preceding::tei:note[@target = 'n1']">
                            <xsl:value-of select="count(preceding::tei:ref[@target = 'n1']) + 2"/>
                        </xsl:when>
                        <!-- all others are plus 1 -->
                        <xsl:otherwise>
                            <xsl:value-of select="count(preceding::tei:ref[@target = 'n1']) + 1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- move @target to @n to store old note number, keep @type -->
        <!--<xsl:comment><xsl:value-of select="$notes-group-number"/></xsl:comment>-->
        <!--<xsl:message select="$notes-group-number"/>-->
        <ref type="{@type}" n="{@target}" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="target" select="$notes/tei:notes/tei:div2/tei:div3[number($notes-group-number)]/tei:note[@n = $print-number]/@xml:id"/>
            <xsl:apply-templates select="*"/>
        </ref>
    </xsl:template>
 

</xsl:stylesheet>
