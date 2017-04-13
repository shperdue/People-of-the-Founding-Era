<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="saxon"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:pm="http://demo.dataformat.com/local/pm"
    xmlns:ptjrs="http://ptjrs.dataformat.com/ptjrs"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:saxon="http://saxon.sf.net/"  version="3.0">

    <!-- 
    place dates into all entries  
    reference date-map.xml for distinct values of months use here
    -->
    
    <!-- 
         use @n to store date. Likely best approach would be to add @when to <tr> in TEI ODD. TBD 
    -->


    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    
    <xsl:variable name="date-map" select="doc('date-map.xml')"/>

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
    
    <xsl:template match="tei:tr" exclude-result-prefixes="#all">
        <xsl:variable name="year" select="replace(normalize-space(ancestor::tei:div1/tei:head),'[\D]','')"/>
        <xsl:variable name="month">
            <xsl:choose>
                <!-- when the row's role is month, and not an 'x' or check month, use the value to look up the number of the month -->
                <xsl:when test="@role[contains(.,'month')] and tei:td[1][normalize-space(lower-case(.)) != 'x'][normalize-space(lower-case(.)) != 'r'][normalize-space(.) != '✓']">
                    <xsl:variable name="month-cell-value" select="replace(normalize-space(tei:td[1]),'([\d\.\s✓X&#x2002;&#x2003;-]+|^c\.)','')"/>
                    <xsl:choose>
                        <xsl:when test="$date-map/date-map/month[name[. = $month-cell-value]]/@number">
                            <xsl:value-of select="$date-map/date-map/month[name[. = $month-cell-value]]/@number"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$month-cell-value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- 'x' months need to look for the preceding month that had a real month, not 'x'
                      It may be in a preceding table. But they're no different than looking for an
                      xday, sday, etc., so we use the same logic
                -->
                <xsl:otherwise>
                    <!-- sometimes no month sibling owing to table break. Look at the last month in the preceding table -->
                    <xsl:choose>
                        <!-- if there is one, use the first non 'x' or '✓' preceding month sibling -->
                        <xsl:when test="preceding-sibling::tei:tr[@role[contains(.,'month')] and tei:td[1][normalize-space(lower-case(.)) != 'x'][normalize-space(lower-case(.)) != 'r'][normalize-space(.) != '✓']]">
                            <xsl:variable name="month-cell-value" select="replace(normalize-space(preceding-sibling::tei:tr[@role[contains(.,'month')] and tei:td[1][normalize-space(lower-case(.)) != 'x'][normalize-space(.) != '✓'][normalize-space(lower-case(.)) != 'r']][1]/tei:td[1]),'([\d\.\sX✓&#x2002;&#x2003;-]+|^c\.)','')"/>
                            <xsl:value-of select="$date-map/date-map/month[name[. = $month-cell-value]]/@number"/>
                        </xsl:when>
                        <xsl:otherwise>                            
                            <xsl:variable name="month-cell-value" select="replace(normalize-space(preceding::tei:tr[@role[contains(.,'month')]][tei:td[1][normalize-space(lower-case(.)) != 'x']][normalize-space(.) != '✓'][normalize-space(lower-case(.)) != 'r'][1]/tei:td[1]),'([\d\.\sX✓&#x2002;&#x2003;-]+|^c\.)','')"/>
                            <xsl:value-of select="$date-map/date-map/month[name[. = $month-cell-value]]/@number"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="day">
            <xsl:choose>
                <!-- if this is a month or a day, and there is content in cell two, use it -->
                <xsl:when test="(@role = 'day' or contains(@role,'month')) and tei:td[2][normalize-space(.) != '']">
                    <!-- remove non digit content to get day -->
                    <xsl:value-of select="replace(tei:td[2],'[\D]','')"/>
                </xsl:when>
                <!-- if a month row first cell spans with a date, use it -->
                <xsl:when test="@role[contains(.,'month')] and tei:td[1][@colspan = 3][matches(.,'\d{1,2}')]">
                    <xsl:value-of select="replace(tei:td[1],'\D+(\d{1,2})\D+\d*','$1')"/>
                </xsl:when>
                <!-- if this is a month and there really is no day, leave blank -->
                <xsl:when test="contains(@role,'month') and tei:td[2][normalize-space(.) = '']"/>
                <!-- otherwise get the first day available -->
                <xsl:otherwise>
                    <!-- sometimes there's not a preceding sibling owing to a table break. Check first. -->
                    <xsl:choose>
                        <!-- When there is a preceding sibling with date, use it. This is the non column spanning version. -->
                        <xsl:when test="preceding-sibling::tei:tr[@role = 'day' or contains(@role,'month')][not(tei:td[1][@colspan])]">
                            <xsl:value-of select="replace(preceding-sibling::tei:tr[@role = 'day' or contains(@role,'month')][1]/tei:td[2],'[\D]','')"/>
                        </xsl:when>
                        <!-- When there is a preceding sibling with date, use it. This is the column spanning version. -->
                        <xsl:when test="preceding-sibling::tei:tr[@role = 'day' or contains(@role,'month')][tei:td[1][@colspan][matches(.,'\d{1,2}')]]">
                            <xsl:value-of select="replace(preceding-sibling::tei:tr[@role = 'day' or contains(@role,'month')][1]/tei:td[1],'\D+(\d{1,2})\D+\d*','$1')"/>
                        </xsl:when>
                        <!-- if no preceding sibling tr, must look to the previous tables for it -->
                        <xsl:otherwise>
                            <xsl:value-of select="replace(preceding::tei:tr[@role = 'day' or contains(@role,'month')][1]/tei:td[2],'[\D]','')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="date">
            <xsl:value-of select="$year"/>
            <xsl:if test="$month != ''">
                <xsl:value-of select="concat('-', $month)"/>
                <!-- only put in date if there's a month -->
                <xsl:if test="$day != ''">
                    <xsl:value-of select="concat('-', format-number($day,'00'))"/>
                </xsl:if>
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@role = 'etbt'">
                <tr xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:apply-templates select="@*, *"/>
                </tr>
            </xsl:when>
            <xsl:otherwise>
<!--                <xsl:comment><xsl:value-of select="concat($year, '-', $month, '-', $day)"/></xsl:comment>-->
                <tr xmlns="http://www.tei-c.org/ns/1.0" n="{$date}">
                    <xsl:apply-templates select="@*, *"/>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 

</xsl:stylesheet>
