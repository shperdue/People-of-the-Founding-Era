<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="saxon"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:pm="http://demo.dataformat.com/local/pm"
    xmlns:ptjrs="http://ptjrs.dataformat.com/ptjrs"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:saxon="http://saxon.sf.net/"  version="3.0">

    <!-- 
    place embedded tables into the main table stream   
    -->


    <xsl:output method="xml" indent="yes" encoding="UTF-8" />

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
 
 <!-- we're looking for non etbt tables immediately followed by etbt table(s) -->
    <xsl:template match="tei:table[not(tei:tr[@role = 'etbt'])][following-sibling::tei:table[1]/tei:tr[@role = 'etbt']]" exclude-result-prefixes="#all">
        <!-- identify the first following sibling that is NOT an etbt -->
        <xsl:variable name="first-non-etbt" select="generate-id(following-sibling::tei:table[not(tei:tr[@role = 'etbt'])][1])"/>
        <!-- get the role of the last row in the table we're embedding in -->
        <xsl:variable name="role" select="./tei:tr[position() = last()]/@role"/>
        <table xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*, * | comment() | processing-instruction()"/>
            <!-- no put in the new row and embed the tables -->
            <tr valign="top" role="{$role}">
                <td colspan="3" width="18.75%"/>
                <td>
                    <xsl:for-each select="following-sibling::tei:table[tei:tr[@role = 'etbt']]">
                        <!-- include those without siblings as they are at the end of a div -->
                        <xsl:if test="following-sibling::tei:table[generate-id() = $first-non-etbt] or not(following-sibling::tei:table)">
                            <xsl:message>got it</xsl:message>
                            <xsl:comment>embedded table to check</xsl:comment>
                            <xsl:copy-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </table>
    </xsl:template>
    
    <!-- bravely delete etbts (ugh), but not the already embedded ones -->
    <xsl:template match="tei:table[tei:tr[@role = 'etbt']]">
        <xsl:choose>
            <xsl:when test="parent::tei:td">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    



</xsl:stylesheet>
