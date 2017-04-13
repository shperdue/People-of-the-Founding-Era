<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="saxon"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:pm="http://demo.dataformat.com/local/pm"
    xmlns:ptjrs="http://ptjrs.dataformat.com/ptjrs"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:saxon="http://saxon.sf.net/"  version="3.0">

    <!-- 
     clean up dates from first pass
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
    
    <xsl:template match="tei:tr[@role != 'etbt']" exclude-result-prefixes="#all">
        <xsl:choose>
            <!-- everybody with a good date can pass on through -->
            <xsl:when test="matches(@n,'^\d\d\d\d-\d\d-\d\d$')">
                <tr xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:apply-templates select="@*, *"/>
                </tr>            
            </xsl:when>
            <!-- otherwise we gotta try and fix you up -->
            <xsl:otherwise>
                <xsl:choose>
                    <!-- when you're missing just a day, gotta go back and get the last one
                         or the day is just completely fubar.... 
                    -->
                    <xsl:when test="matches(@n,'^\d\d\d\d-\d\d$') or matches(@n,'-\d{3,}$')">
                        <xsl:processing-instruction name="check"><xsl:text>day part of date</xsl:text></xsl:processing-instruction>
                        <xsl:variable name="date-candidate" select="substring(preceding::tei:tr[matches(@n,'\d\d\d\d-\d\d-\d\d')][1]/@n,9,2)"/>
                        <xsl:variable name="repaired-date" select="concat(tokenize(@n,'-')[1],'-',tokenize(@n,'-')[2],'-',$date-candidate)"/>
                        <tr xmlns="http://www.tei-c.org/ns/1.0" n="{$repaired-date}">
                            <xsl:apply-templates select="@*[not(name() = 'n')], *"/>
                        </tr>   
                    </xsl:when>
                    <!-- when you're just a year, we gotta go get the last month and date -->
                    <xsl:when test="matches(@n,'^\d\d\d\d$')">
                        <xsl:processing-instruction name="check"><xsl:text>month and day part of date</xsl:text></xsl:processing-instruction>
                        <xsl:variable name="month-candidate" select="substring(preceding::tei:tr[matches(@n,'\d\d\d\d-\d\d-\d\d')][1]/@n,6,2)"/>
                        <xsl:variable name="date-candidate" select="substring(preceding::tei:tr[matches(@n,'\d\d\d\d-\d\d-\d\d')][1]/@n,9,2)"/>
                        <xsl:variable name="repaired-date" select="concat(@n,'-',$month-candidate,'-',$date-candidate)"/>
                        <tr xmlns="http://www.tei-c.org/ns/1.0" n="{$repaired-date}">
                            <xsl:apply-templates select="@*[not(name() = 'n')], *"/>
                        </tr>   
                    </xsl:when>
                    <!-- otherwise you might be beyond help and need a checkin! -->
                    <xsl:otherwise>
                        <xsl:processing-instruction name="check"><xsl:text>entire date</xsl:text></xsl:processing-instruction>
                        <tr xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:apply-templates select="@*, *"/>
                        </tr>  
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 

</xsl:stylesheet>
