<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:darma="http://www.dataformat.com/darma"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="#all" version="3.0">

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet" type="stylesheet">
    <desc>
      <p>Darma-to-PFE.xsl: XSLT stylesheet to concatenate information sources into
        unique individual per-person entries for further use in an XML database.</p>
      <p><b>Requirements:</b></p>
      <ul>
        <li>Data files (ADMS.xml, ARHN.xml, Ash.xml, BNFN.xml, BR.xml, Bios-collection.xml, CFG.xml, DD.xml, DH.xml, DMDE.xml, Flourishes.xml, GEWN.xml, GS.xml, JSMN.xml, Occupations.xml, Organizations.xml, PFE.xml, PS.xml, Places.xml, Roles.xml, TSJN.xml, VP.xml)
        </li>
        <li>An XSLT 3.0-aware processor. This script as written assumes use of the Saxon XSLT processor
        (www.saxonica.com) with the saxon:find() function, but that can be rewritten if necessary for
        use with a different XSLT engine; see http://saxonica.com/html/documentation/functions/saxon/index-1.html.</li>
      </ul>
      <p>
        <pre>This software is dual-licensed:
    1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
    Unported License http://creativecommons.org/licenses/by-sa/3.0/ 
    
    2. http://www.opensource.org/licenses/BSD-2-Clause
   
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are
    met:
    
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    
    This software is provided by the copyright holders and contributors
    "as is" and any express or implied warranties, including, but not
    limited to, the implied warranties of merchantability and fitness for
    a particular purpose are disclaimed. In no event shall the copyright
    holder or contributors be liable for any direct, indirect, incidental,
    special, exemplary, or consequential damages (including, but not
    limited to, procurement of substitute goods or services; loss of use,
    data, or profits; or business interruption) however caused and on any
    theory of liability, whether in contract, strict liability, or tort
    (including negligence or otherwise) arising in any way out of the use
    of this software, even if advised of the possibility of such damage.</pre>
      </p>
      <p>Authors: Shannon Shiflett, David Sewell</p>    
      <p>Copyright: 2017 by the Rector and Visitors of the University of Virginia</p>
    </desc>
  </doc>

  <!-- use verbose=yes to emit message when a linked bio is found
       (as well as not found) -->
  <xsl:param name="verbose">no</xsl:param>
  <!-- Name of output directory relative to current -->
  <xsl:param name="outputDir">load</xsl:param>

  <xsl:output indent="yes"/>

  <!-- index all darma:Object bios by @xml:id -->
  <xsl:variable name="indexedBios" as="map(*)"
    select="saxon:index(collection('Bios-collection.xml')//darma:Object, function($t){$t/@xml:id})"/>
  <xsl:variable name="indexedPeople" as="map(*)"
    select="saxon:index(doc('PFE.xml')//darma:Object, function($t){$t/@xml:id})"/>
  <xsl:variable name="countableLinks" as="map(*)"
    select="saxon:index(doc('PFE.xml')//darma:Links/darma:Link[starts-with(@type, 'Family:') 
    or starts-with(@type, 'Servitude:')], function($t){$t/@targetID})"/>
  <xsl:variable name="indexedOccupations" as="map(*)"
    select="saxon:index(doc('Occupations.xml')//darma:Object, function($t){$t/@xml:id})"/>
  <xsl:variable name="indexedOrganizations" as="map(*)"
    select="saxon:index(doc('Organizations.xml')//darma:Object, function($t){$t/@xml:id})"/>
  <xsl:variable name="indexedRoles" as="map(*)"
    select="saxon:index(doc('Roles.xml')//darma:Object, function($t){$t/@xml:id})"/>
  <xsl:variable name="indexedFlour" as="map(*)"
    select="saxon:index(doc('Flourishes.xml')//darma:Object, function($t){$t/@xml:id})"/>
  <xsl:variable name="indexedPlaces" as="map(*)"
    select="saxon:index(doc('Places.xml')//darma:Object, function($t){$t/@xml:id})"/>
  
  <xsl:template name="main">
    <xsl:for-each select="doc('PFE.xml')//darma:Object">
      <xsl:variable name="ID" select="substring-after(@xml:id,'o')" as="xs:string"/>
      
      <xsl:variable name="sex" select="lower-case(normalize-space(darma:Metadata/darma:Datum[@fieldName='person.gender']/darma:Value))"/>   
      
      <xsl:variable name="birthPlace" as="node()?">
        <xsl:if test="darma:Metadata/darma:Datum[@fieldID='f166']">
            <xsl:copy-of select="map:get($indexedPlaces, concat('o', string(darma:Metadata/darma:Datum[@fieldID='f166']/darma:Value[1]/@subjectRefID)))"/>
        </xsl:if>
      </xsl:variable>
      
      <xsl:variable name="deathPlace" as="node()?">
        <xsl:if test="darma:Metadata/darma:Datum[@fieldID='f168']">
          <xsl:copy-of select="map:get($indexedPlaces, concat('o', string(darma:Metadata/darma:Datum[@fieldID='f168']/darma:Value[1]/@subjectRefID)))"/>
        </xsl:if>
      </xsl:variable>

      <xsl:variable name="linkedBios"
        select="for $link in darma:Links/darma:Link return string($link/@targetID) ! $indexedBios(.)"
        as="node()*"/>
      <xsl:result-document href="{$outputDir}/{concat($ID, '.xml')}">
        <people xmlns="http://rotunda.upress.virginia.edu/pfe">
          <!-- deleting targets attribute -->
          <person id="{$ID}">
            <fullname>
              <xsl:value-of select="normalize-space(darma:Name)"/>
            </fullname>
            <sex>
              <xsl:choose>
                <xsl:when test="$sex eq 'm'">
                  <xsl:text>Man</xsl:text>
                </xsl:when>
                <xsl:when test="$sex eq 'f'">
                  <xsl:text>Woman</xsl:text>
                </xsl:when>
                <xsl:otherwise><!--<xsl:text>undetermined</xsl:text>--></xsl:otherwise>
              </xsl:choose>
            </sex>
            <!-- forename with @n and @type -->
            <xsl:if test="darma:Metadata/darma:Datum[matches(@fieldName, 'person.Forename[\d]$')]">
              <xsl:for-each select="darma:Metadata/darma:Datum[matches(@fieldName, 'person.Forename[\d]$')]">
                <xsl:variable name="count" select="substring-after(./@fieldName, 'Forename')" />
                <forename>
                  <xsl:attribute name="n" select="$count "/>
                  <xsl:if test="../darma:Datum[matches(@fieldName, concat('person.Forename',$count,'Type'))]">
                    <xsl:attribute name="type" select="normalize-space(../darma:Datum[matches(@fieldName, concat('person.Forename',$count,'Type'))]/darma:Value)"/>
                  </xsl:if>
                  <xsl:value-of select="normalize-space(./darma:Value)"/>                 
                </forename>
              </xsl:for-each>
            </xsl:if>
            <!-- surname with @n and @type -->
            <xsl:if test="darma:Metadata/darma:Datum[matches(@fieldName, 'person.Surname[\d]$')]">
              <xsl:for-each select="darma:Metadata/darma:Datum[matches(@fieldName, 'person.Surname[\d]$')]">
                <xsl:variable name="count" select="substring-after(./@fieldName, 'Surname')" />
                <surname>
                  <xsl:attribute name="n" select="$count"/>
                  <xsl:if test="../darma:Datum[matches(@fieldName, concat('person.Surname',$count,'Type'))]">
                    <xsl:attribute name="type" select="normalize-space(../darma:Datum[matches(@fieldName, concat('person.Surname',$count,'Type'))]/darma:Value)"/>
                  </xsl:if>                  
                  <xsl:value-of select="normalize-space(./darma:Value)"/>                 
                </surname>
              </xsl:for-each>
            </xsl:if>
            <!-- gen -->
            <xsl:if test="darma:Metadata/darma:Datum[@fieldName='person.genName']">
                <gen>
                  <xsl:value-of select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.genName']/darma:Value)"/>                 
                </gen>
            </xsl:if>
            <xsl:if test="darma:Metadata/darma:Datum[@fieldName='person.faithControlled']">
              <faith>
                <xsl:for-each select="darma:Metadata/darma:Datum[@fieldName='person.faithControlled']/darma:Value">
                  <religion><xsl:value-of select="normalize-space(.)"/></religion>
                </xsl:for-each>                 
              </faith>
            </xsl:if>
            <!-- birthdate with @date and @cert and place elements -->
            <xsl:if test="darma:Metadata/darma:Datum[@fieldName='person.birthDate']">
              <!-- date metadata for bucketed faceted constraint indexes -->
              <xsl:variable name="when" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.birthDate']/darma:Value[@type='when'])"/>
              <xsl:variable name="from" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.birthDate']/darma:Value[@type='from'])"/>
              <xsl:variable name="to" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.birthDate']/darma:Value[@type='to'])"/>
              <xsl:variable name="notBefore" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.birthDate']/darma:Value[@type='notBefore'])"/>
              <xsl:variable name="notAfter" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.birthDate']/darma:Value[@type='notAfter'])"/>
              <xsl:variable name="birthPlaceCountry" as="xs:string?" select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.Country']/darma:Value)"/>
              <!-- include country/state metadata only for US values. International ones are too variable and confusing in context. -->
              <xsl:variable name="birthPlaceCounty" as="xs:string*">
                <xsl:choose>
                  <xsl:when test="$birthPlaceCountry eq 'United States'">
                    <xsl:value-of select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.County']/darma:Value)"/>
                  </xsl:when>
                  <xsl:otherwise><!-- null --></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="birthPlaceState" as="xs:string*">
                <xsl:choose>
                  <xsl:when test="$birthPlaceCountry eq 'United States'">
                    <xsl:value-of select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.State']/darma:Value)"/>
                  </xsl:when>
                  <xsl:otherwise><!-- null --></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>>
              <birth>
                <xsl:variable name="whenBirthYear" select="substring($when, 1, 4)"/>
                <xsl:if test="$whenBirthYear castable as xs:gYear">
                  <xsl:attribute name="year" >
                    <xsl:value-of select="$whenBirthYear"/>
                  </xsl:attribute>
                </xsl:if>
                
                <date>
                  <xsl:if test="$when">
                    <xsl:attribute name="when">
                      <xsl:value-of select="$when"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$from">
                    <xsl:attribute name="from">
                      <xsl:value-of select="$from"/>
                    </xsl:attribute>
                    <xsl:attribute name="to">
                      <xsl:value-of select="$to"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$notBefore">
                    <xsl:attribute name="notBefore">
                      <xsl:value-of select="$notBefore"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$notAfter">
                    <xsl:attribute name="notAfter">
                      <xsl:value-of select="$notAfter"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:attribute name="cert">
                    <xsl:value-of select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.birthDate']/darma:Value[@type='cert'])"/>
                  </xsl:attribute>
                  <xsl:attribute name="precision">
                    <xsl:value-of select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.birthDate']/darma:Value[@type='precision'])"/>
                  </xsl:attribute>
                </date>
                <!-- place elements -->
                <xsl:if test="$birthPlace/darma:Metadata/darma:Datum[@fieldName='place.Settlement']">
                  <settlement>
                    <xsl:value-of select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.Settlement']/darma:Value)"/>
                  </settlement>
                </xsl:if>
                <!-- replacing region1 and region2 with state and county -->
                <xsl:if test="$birthPlaceCounty">
                  <county>
                    <xsl:value-of select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.County']/darma:Value)"/>
                  </county>
                </xsl:if>
                <xsl:if test="$birthPlaceState">
                  <state>
                    <xsl:value-of select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.State']/darma:Value)"/>
                  </state>
                </xsl:if>
                <xsl:if test="$birthPlace/darma:Metadata/darma:Datum[@fieldName='place.Country']">
                  <country>
                    <xsl:value-of select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.Country']/darma:Value)"/>
                  </country>
                </xsl:if>
              </birth>
            </xsl:if>
            <!-- deathdate with @date and @cert and place elements -->
            <xsl:if test="darma:Metadata/darma:Datum[@fieldName='person.deathDate']">
              <!-- date metadata for bucketed faceted constraint indexes -->
              <xsl:variable name="when" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.deathDate']/darma:Value[@type='when'])"/>
              <xsl:variable name="from" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.deathDate']/darma:Value[@type='from'])"/>
              <xsl:variable name="to" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.deathDate']/darma:Value[@type='to'])"/>
              <xsl:variable name="notBefore" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.deathDate']/darma:Value[@type='notBefore'])"/>
              <xsl:variable name="notAfter" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.deathDate']/darma:Value[@type='notAfter'])"/>
              <xsl:variable name="deathPlaceCountry" as="xs:string?" select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.Country']/darma:Value)"/>
              <xsl:variable name="deathPlaceCounty" as="xs:string*">
                <xsl:choose>
                  <xsl:when test="$deathPlaceCountry eq 'United States'">
                    <xsl:value-of select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.County']/darma:Value)"/>
                  </xsl:when>
                  <xsl:otherwise><!-- null --></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="deathPlaceState" as="xs:string*">
                <xsl:choose>
                  <xsl:when test="$deathPlaceCountry eq 'United States'">
                    <xsl:value-of select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.State']/darma:Value)"/>
                  </xsl:when>
                  <xsl:otherwise><!-- null --></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <death>
                <xsl:variable name="whenDeathYear" select="substring($when, 1, 4)"/>
                <xsl:if test="$whenDeathYear castable as xs:gYear">
                  <xsl:attribute name="year" >
                    <xsl:value-of select="$whenDeathYear"/>
                  </xsl:attribute>
                </xsl:if>
                <date>
                  <xsl:if test="$when">
                    <xsl:attribute name="when">
                      <xsl:value-of select="$when"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$from">
                    <xsl:attribute name="from">
                      <xsl:value-of select="$from"/>
                    </xsl:attribute>
                    <xsl:attribute name="to">
                      <xsl:value-of select="$to"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$notBefore">
                    <xsl:attribute name="notBefore">
                      <xsl:value-of select="$notBefore"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$notAfter">
                    <xsl:attribute name="notAfter">
                      <xsl:value-of select="$notAfter"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:attribute name="cert">
                    <xsl:value-of select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.deathDate']/darma:Value[@type='cert'])"/>
                  </xsl:attribute>
                  <xsl:attribute name="precision">
                    <xsl:value-of select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.deathDate']/darma:Value[@type='precision'])"/>
                  </xsl:attribute>
                </date>
                <!-- place elements -->
                <xsl:if test="$deathPlace/darma:Metadata/darma:Datum[@fieldName='place.Settlement']">
                  <settlement>
                    <xsl:value-of select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.Settlement']/darma:Value)"/>
                  </settlement>
                </xsl:if>
                <!-- replacing region1 and region2 with state and county -->
                <xsl:if test="$deathPlaceCounty">
                  <county>
                    <xsl:value-of select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.County']/darma:Value)"/>
                  </county>
                </xsl:if>
                <xsl:if test="$deathPlaceState">
                  <state>
                    <xsl:value-of select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.State']/darma:Value)"/>
                  </state>
                </xsl:if>
                <xsl:if test="$deathPlace/darma:Metadata/darma:Datum[@fieldName='place.Country']">
                  <country>
                    <xsl:value-of select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.Country']/darma:Value)"/>
                  </country>
                </xsl:if>
              </death>
            </xsl:if>
            <!-- constructed date metadata -->
            <xsl:if test="darma:Metadata/darma:Datum[@fieldName='person.deathDate'] and darma:Metadata/darma:Datum[@fieldName='person.deathDate']">
              <xsl:variable name="whenDeath" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.deathDate']/darma:Value[@type='when'])"/>
              <xsl:variable name="whenBirth" select="normalize-space(darma:Metadata/darma:Datum[@fieldName='person.birthDate']/darma:Value[@type='when'])"/>
              <xsl:if test="$whenBirth and $whenDeath">
                <xsl:variable name="whenDeathYear" select="substring($whenDeath, 1, 4)"></xsl:variable>
                <xsl:variable name="whenBirthYear" select="substring($whenBirth, 1, 4)"></xsl:variable>
                <xsl:if test="$whenDeathYear castable as xs:gYear and $whenBirthYear castable as xs:gYear">
                  <xsl:variable name="duration" select="xs:integer($whenDeathYear) - xs:integer($whenBirthYear)"></xsl:variable>
                  <lived><xsl:value-of select="$duration"/></lived>  
                </xsl:if>
              </xsl:if>
            </xsl:if>
            <!-- constructed place of origin metadata -->
            <xsl:if test="$birthPlace">
              <born>
                <xsl:variable name="s" select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.Settlement']/darma:Value)"/>
                <xsl:variable name="c" select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.Country']/darma:Value)"/>
                <xsl:variable name="st" select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.State']/darma:Value)"/>
                <xsl:variable name="co" select="normalize-space($birthPlace/darma:Metadata/darma:Datum[@fieldName='place.County']/darma:Value)"/>
                <xsl:if test="$s">
                <s><xsl:value-of select="$s"/></s>
                </xsl:if>
                <xsl:if test="$st">
                  <st><xsl:value-of select="$st"/></st>
                </xsl:if>
                <xsl:if test="$co">
                  <co><xsl:value-of select="$co"/></co>
                </xsl:if>
                <xsl:if test="$c">
                  <c><xsl:value-of select="$c"/></c>
                </xsl:if>
              </born>
            </xsl:if>           
            <!-- constructed place of origin metadata -->
            <xsl:if test="$deathPlace">
              <died>
                <xsl:variable name="s-died" select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.Settlement']/darma:Value)"/>
                <xsl:variable name="c-died" select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.Country']/darma:Value)"/>
                <xsl:variable name="st-died" select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.State']/darma:Value)"/>
                <xsl:variable name="co-died" select="normalize-space($deathPlace/darma:Metadata/darma:Datum[@fieldName='place.County']/darma:Value)"/>
                <xsl:if test="$s-died">
                  <s-died><xsl:value-of select="$s-died"/></s-died>
                </xsl:if>
                <xsl:if test="$st-died">
                  <st-died><xsl:value-of select="$st-died"/></st-died>
                </xsl:if>
                <xsl:if test="$co-died">
                  <co-died><xsl:value-of select="$co-died"/></co-died>
                </xsl:if>
                <xsl:if test="$c-died">
                  <c-died><xsl:value-of select="$c-died"/></c-died>
                </xsl:if>
              </died>
            </xsl:if>
            
            <!-- possible duplicates -->
            
            <duplicates>
              <xsl:attribute name="count">
                <xsl:value-of select="count(darma:Links/darma:Link[starts-with(@type, 'Possible')])"/>
              </xsl:attribute>
              <xsl:for-each select="darma:Links/darma:Link[starts-with(@type, 'Possible')]">   
                <xsl:variable name="person" select="map:get($indexedPeople, ./@targetID)"/>
                <duplicate>
                  <xsl:attribute name="type">Possible Duplicate</xsl:attribute>
                  <xsl:attribute name="id">
                    <xsl:value-of select="substring-after($person/@xml:id,'o')"/>
                  </xsl:attribute>
                  <xsl:if test="./@info2">
                    <xsl:attribute name="desc">
                      <xsl:value-of select="./@info2"/>
                    </xsl:attribute>
                  </xsl:if>      
                  <xsl:value-of select="$person/darma:Name"/>
                </duplicate>                
              </xsl:for-each>
            </duplicates>
            
            <!-- social -->
            
            <socialization>
              <xsl:attribute name="count">
                <xsl:value-of select="count(darma:Links/darma:Link[starts-with(@type, 'Social')])"/>
              </xsl:attribute>
              <xsl:for-each select="darma:Links/darma:Link[starts-with(@type, 'Social')]">   
                    <xsl:variable name="person" select="map:get($indexedPeople, ./@targetID)"/>
                    <social>
                      <xsl:attribute name="type">
                        <xsl:value-of select="substring-after(@type,'Social: ')"/>
                      </xsl:attribute>
                      <xsl:attribute name="id">
                        <xsl:value-of select="substring-after($person/@xml:id,'o')"/>
                      </xsl:attribute>
                      <xsl:value-of select="$person/darma:Name"/>
                    </social>                
              </xsl:for-each>
            </socialization>
            
            <!-- business -->
            
            <businesses>
              <xsl:attribute name="count">
                <xsl:value-of select="count(darma:Links/darma:Link[starts-with(@type, 'Business')])"/>
              </xsl:attribute>
              <xsl:for-each select="darma:Links/darma:Link[starts-with(@type, 'Business')]">
                <xsl:choose>
                  <xsl:when test="contains(@type, 'Member') or contains(@type, 'Shareholder')">
                    <xsl:variable name="org" select="map:get($indexedOrganizations, ./@targetID)"/>
                    <business>
                      <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Dates']">
                        <xsl:attribute name="dates">
                          <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Dates']/darma:Value"/>
                        </xsl:attribute>
                      </xsl:if>                  
                      <xsl:attribute name="type">
                        <xsl:choose>
                          <xsl:when test="contains(@type, 'Member')">Member of</xsl:when>
                          <xsl:otherwise>Shareholder</xsl:otherwise>
                        </xsl:choose>
                      </xsl:attribute>
                      <xsl:value-of select="$org/darma:Name"/>
                    </business>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:variable name="person" select="map:get($indexedPeople, ./@targetID)"/>
                    <business>
                      <xsl:attribute name="type">
                        <xsl:value-of select="substring-after(@type,'Business: ')"/>
                      </xsl:attribute>
                      <xsl:attribute name="id">
                        <xsl:value-of select="substring-after($person/@xml:id,'o')"/>
                      </xsl:attribute>
                      <xsl:value-of select="$person/darma:Name"/>
                    </business>
                  </xsl:otherwise>
                </xsl:choose>
                
              </xsl:for-each>
            </businesses>
            
            <!-- organization(s) -->
            
            <organizations>
              <xsl:attribute name="count">
                <xsl:value-of select="count(darma:Links/darma:Link[starts-with(@type, 'Organization')])"/>
              </xsl:attribute>
              <xsl:for-each select="darma:Links/darma:Link[starts-with(@type, 'Organization')]">
                <xsl:variable name="org" select="map:get($indexedOrganizations, ./@targetID)"/>
                <organization>
                  <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Dates']">
                    <xsl:attribute name="dates">
                      <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Dates']/darma:Value"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:attribute name="type">
                    <xsl:choose>
                      <xsl:when test="contains(@type, 'Head')">Head</xsl:when>
                      <xsl:when test="contains(@type, 'Founder')">Founder</xsl:when>
                      <xsl:otherwise>Member</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:value-of select="$org/darma:Name"/>
                </organization>
              </xsl:for-each>
            </organizations>
            
            <!-- government links -->
            
            <governments>
              <xsl:attribute name="count">
                <xsl:value-of select="count(darma:Links/darma:Link[starts-with(@type, 'Government')])"/>
              </xsl:attribute>
              <xsl:for-each select="darma:Links/darma:Link[starts-with(@type, 'Government')]">
                <xsl:variable name="org" select="map:get($indexedOrganizations, ./@targetID)"/>
                <government>
                  <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Dates']">
                    <xsl:attribute name="dates">
                      <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Dates']/darma:Value"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Leader']">
                    <xsl:attribute name="leader">
                      <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Leader']/darma:Value"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Preceding']">
                    <xsl:attribute name="preceding">
                      <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Preceding']/darma:Value"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="./@info1">
                    <xsl:attribute name="date">
                      <xsl:value-of select="./@info1"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="./@info2">
                    <xsl:attribute name="desc">
                      <xsl:value-of select="./@info2"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:attribute name="type">
                    <xsl:choose>
                      <xsl:when test="contains(@type, 'Head of')">Head</xsl:when>
                      <xsl:otherwise>Member</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:value-of select="$org/darma:Name"/>
                </government>
              </xsl:for-each>
            </governments>
            
            <!-- education links -->
            
            <edus>
              <xsl:attribute name="count">
                <xsl:value-of select="count(darma:Links/darma:Link[starts-with(@type, 'Education')])"/>
              </xsl:attribute>
              <xsl:for-each select="darma:Links/darma:Link[starts-with(@type, 'Education')]">
                <xsl:choose>
                  <xsl:when test="contains(@type, 'Tutor')">
                    <xsl:variable name="person" select="map:get($indexedPeople, ./@targetID)"/>
                    <edu>
                      <xsl:attribute name="type">Teacher/Tutor of</xsl:attribute>
                      <xsl:attribute name="id">
                        <xsl:value-of select="substring-after($person/@xml:id,'o')"/>
                      </xsl:attribute>
                      <xsl:value-of select="$person/darma:Name"/>
                    </edu>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:variable name="org" select="map:get($indexedOrganizations, ./@targetID)"/>
                    <edu>
                      <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Dates']">
                        <xsl:attribute name="dates">
                          <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Dates']/darma:Value"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Leader']">
                        <xsl:attribute name="leader">
                          <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Leader']/darma:Value"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Preceding']">
                        <xsl:attribute name="preceding">
                          <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Preceding']/darma:Value"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:if test="./@info1">
                        <xsl:attribute name="date">
                          <xsl:value-of select="./@info1"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:if test="./@info2">
                        <xsl:attribute name="desc">
                          <xsl:value-of select="./@info2"/>
                        </xsl:attribute>
                      </xsl:if>                  
                      <xsl:attribute name="type">
                        <xsl:value-of select="substring-after(@type,'Education: ')"/>
                      </xsl:attribute>
                      <xsl:value-of select="$org/darma:Name"/>
                    </edu>
                  </xsl:otherwise>
                </xsl:choose>               
              </xsl:for-each>
            </edus>
            
            <!-- military links -->
            
            <militaryService>
              <xsl:attribute name="count">
                <xsl:value-of select="count(darma:Links/darma:Link[starts-with(@type, 'Military')])"/>
              </xsl:attribute>
              <xsl:for-each select="darma:Links/darma:Link[starts-with(@type, 'Military')]">
                <xsl:variable name="org" select="map:get($indexedOrganizations, ./@targetID)"/>
                <military>
                  <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Dates']">
                    <xsl:attribute name="dates">
                      <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Dates']/darma:Value"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Leader']">
                    <xsl:attribute name="leader">
                      <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Leader']/darma:Value"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$org/darma:Metadata/darma:Datum[@fieldName='org.Preceding']">
                    <xsl:attribute name="preceding">
                      <xsl:value-of select="$org/darma:Metadata/darma:Datum[@fieldName='org.Preceding']/darma:Value"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="./@info1">
                    <xsl:attribute name="date">
                      <xsl:value-of select="./@info1"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="./@info2">
                    <xsl:attribute name="desc">
                      <xsl:value-of select="./@info2"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:attribute name="type">
                    <xsl:choose>
                      <xsl:when test="contains(@type, 'Commander')">Commander</xsl:when>
                      <xsl:when test="contains(@type, 'Ship Captain')">Ship Captain</xsl:when>
                      <xsl:when test="contains(@type, 'Became')">Unit Became</xsl:when>
                      <xsl:otherwise>Served</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:value-of select="$org/darma:Name"/>
                </military>
              </xsl:for-each>
            </militaryService>
            
            <!-- role(s) -->
            
            <roles>
              <xsl:attribute name="count">
                <xsl:value-of select="count(darma:Links/darma:Link[starts-with(@type, 'Role')])"/>
              </xsl:attribute>
              <xsl:for-each select="darma:Links/darma:Link[starts-with(@type, 'Role')]">
                <xsl:variable name="roles" select="map:get($indexedRoles, ./@targetID)"/>
                <role><xsl:value-of select="$roles/darma:Name"/></role>
              </xsl:for-each>
            </roles> 
            
            <!-- flourish(es) -->
            
            <flourishes>
              <xsl:attribute name="count">
                <xsl:value-of select="count(darma:Links/darma:Link[starts-with(@type, 'Flourish')])"/>
              </xsl:attribute>
              <xsl:for-each select="darma:Links/darma:Link[starts-with(@type, 'Flourish')]">
                <xsl:variable name="flour" select="map:get($indexedFlour, ./@targetID)"/>
                <flourish>
                  <xsl:if test="./@info1">
                    <xsl:attribute name="date">
                      <xsl:value-of select="./@info1"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="./@info2">
                    <xsl:attribute name="desc">
                      <xsl:value-of select="./@info2"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="$flour/darma:Name"/>
                </flourish>
              </xsl:for-each>
            </flourishes>   
            
            
            <!-- occupation(s) -->
            
              <occupations>
                <xsl:attribute name="count">
                  <xsl:value-of select="count(darma:Links/darma:Link[@type='Occupation'])"/>
                </xsl:attribute>
                <xsl:for-each select="darma:Links/darma:Link[@type='Occupation']">
                  <xsl:variable name="occ" select="map:get($indexedOccupations, ./@targetID)"/>
                  <xsl:variable name="occT" select="tokenize($occ/darma:Metadata/darma:Datum[@fieldName='occ.Categories']/darma:Value,'-\-')"/>
                  <occupation>
                    <supercat><xsl:value-of select='normalize-space(($occT)[2])'/></supercat>
                    <cat><xsl:value-of select='normalize-space(($occT)[1])'/></cat>
                    <subcat><xsl:value-of select="$occ/darma:Name"/></subcat>
                  </occupation>
                </xsl:for-each>
              </occupations>
           
            <!-- citation, at present a required element -->
            <xsl:if test="darma:Metadata/darma:Datum[@fieldName='person.DCCitation']">
              <DCCitation>
                <xsl:copy-of select="darma:Metadata/darma:Datum[@fieldName='person.DCCitation']/xhtml:html"/>
              </DCCitation>
            </xsl:if>
            <!-- links -->
            <links>
              <!-- following are the key values of all the in-entry links -->
              <xsl:variable name="entry-link-keys" select="darma:Links/darma:Link[starts-with(@type, 'Family:') or starts-with(@type, 'Servitude:')]/@targetID" as="xs:string*"/>
              <xsl:variable name="incoming-links" select="map:get($countableLinks, concat('o', $ID))[not(ancestor::darma:Object/@xml:id = $entry-link-keys)]" as="element()*"/>
              <xsl:attribute name="count">
                <xsl:variable name="links-from-count" select="count($entry-link-keys)"/>
                <xsl:variable name="links-to-count" select="count($incoming-links)"/>
                <xsl:value-of select="$links-from-count + $links-to-count"/>
              </xsl:attribute>
              
              <xsl:for-each select="darma:Links/darma:Link[starts-with(@type, 'Family:') or starts-with(@type, 'Servitude:')]">
                <xsl:variable name="key" select="@targetID"/>
                <link>
                  <xsl:attribute name="key" select="$key"/>
                  <xsl:attribute name="type" select="@type"/>
                  <xsl:attribute name="fullname" select="map:get(
                    $indexedPeople, $key)/darma:Name"/>                    
                </link>
              </xsl:for-each>
             
              <xsl:comment>END OF INTERNAL LINKS</xsl:comment>
              <xsl:text>&#10;         </xsl:text>
              <xsl:for-each select="map:get($countableLinks, concat('o', $ID))[not(ancestor::darma:Object/@xml:id = $entry-link-keys)]">
                <xsl:variable name="key" select="ancestor::darma:Object/@xml:id"></xsl:variable>
                <link>
                  <xsl:if test="$key = $entry-link-keys">
                    <xsl:attribute name="dupe">DUPE</xsl:attribute>
                  </xsl:if>
                  <xsl:attribute name="key" select="$key"/>
                  <xsl:attribute name="type">
                    <!-- reverse the semantics for incoming links. Assymetric relationships are inverted. -->
                    <xsl:choose>
                      <xsl:when test="matches(@type, 'Aunt of|Uncle of')">
                        <xsl:choose>
                          <xsl:when test="$sex eq 'm'">Family: Nephew</xsl:when>
                          <xsl:otherwise>Family: Niece</xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:when test="matches(@type, 'Child of|Adpted Child of|Illegitimate Child of')">
                        <xsl:choose>
                          <xsl:when test="$sex eq 'm'">Family: Father</xsl:when>
                          <xsl:otherwise>Family: Mother</xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:when test="matches(@type, 'Father of|Mother of')">Family: Child</xsl:when>
                      <xsl:when test="matches(@type, 'Grandchild of')">Family: Grandparent</xsl:when>
                      <xsl:when test="matches(@type, 'Grandparent of')">Family: Grandchild</xsl:when>
                      <xsl:when test="matches(@type, 'Nephew of|Niece of')">
                        <xsl:choose>
                          <xsl:when test="$sex eq 'm'">Family: Uncle</xsl:when>
                          <xsl:otherwise>Family: Aunt</xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="@type"></xsl:value-of>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:attribute name="fullname" select="ancestor::darma:Object/darma:Name"/>
                </link>
              </xsl:for-each>
            </links>
            <!-- bio -->
            <bios>
            <xsl:choose>
              <xsl:when test="empty($linkedBios)">
                <xsl:attribute name="count" select="0"/>
                <xsl:message>NO LINKED BIOS for person with ID=<xsl:value-of select="$ID"/></xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="$verbose eq 'yes'">
                  <xsl:message>FOUND: linked bio for person with ID=<xsl:value-of select="$ID"/></xsl:message>
                </xsl:if>
                <xsl:attribute name="count">
                    <xsl:value-of select="count($linkedBios/darma:Metadata/darma:Datum[@fieldName='biographies.Bio'])"/>
                </xsl:attribute>
                <xsl:for-each select="$linkedBios/darma:Metadata/darma:Datum[@fieldName='biographies.Bio']">
                  <xsl:variable name="project" select="../darma:Datum[@fieldName='biographies.Cite']"/>
                  
                    <bio>       
                      <xsl:attribute name="project">                    
                        <xsl:choose>
                          <xsl:when test="contains($project,'Adams')">Adams Papers</xsl:when>
                          <xsl:when test="contains($project,'Franklin')">Franklin Papers</xsl:when>
                          <xsl:when test="contains($project,'Jefferson')">Jefferson Papers</xsl:when>
                          <xsl:when test="contains($project,'Rush')">Rush Papers</xsl:when>
                          <xsl:when test="contains($project,'James Madison')">Madison Papers</xsl:when>
                          <xsl:when test="contains($project,'Washington')">Washington Papers</xsl:when>
                          <xsl:when test="contains($project,'Dolley Madison')">Dolley Madison Papers</xsl:when>
                          <xsl:when test="contains($project,'Hamilton')">Hamilton Papers</xsl:when>
                          <xsl:when test="contains($project,'Documentary History')">Documentary History</xsl:when>
                          <xsl:when test="contains($project,'Horry')">Pinckney Horry</xsl:when>
                          <xsl:when test="ancestor::darma:Object/@collectionID eq 'c366'">Ash Lawn-Highland Sources</xsl:when>
                          <xsl:when test="ancestor::darma:Object/@collectionID eq 'c359'">Virginia Printers</xsl:when>
                          <xsl:when test="ancestor::darma:Object/@collectionID eq 'c365'">The Geography of Slavery</xsl:when>
                          <xsl:when test="ancestor::darma:Object/@collectionID eq 'c376'">Creating a Federal Government</xsl:when>
                          <xsl:when test="ancestor::darma:Object/@collectionID eq 'c197'">Drinker Diaries</xsl:when>
                          <xsl:otherwise>Other</xsl:otherwise>
                        </xsl:choose>
                      </xsl:attribute>

                      <div>
                        <xsl:copy-of select="./xhtml:html/xhtml:body" copy-namespaces="no"/>
                      </div>
                      
                      <xsl:if test="ancestor::darma:Object/@collectionID eq 'c365'">
                        <xsl:variable name="costa" select="../darma:Datum[starts-with(@fieldName, 'Costa.')][darma:Value ne 'No data available']"/>
                        <xsl:if test="$costa">
                          <xsl:for-each select="$costa">
                            <xsl:element name="costa">
                              <xsl:attribute name="type"><xsl:value-of select="substring-after(@fieldName, '.')"/></xsl:attribute>
                              <xsl:value-of select="./darma:Value"/>
                            </xsl:element>
                          </xsl:for-each>
                        </xsl:if>
                      </xsl:if>
                      
                      <xsl:choose>
                        <xsl:when test="../darma:Datum[@fieldName='biographies.Cite']">
                          <cite>
                            <xsl:apply-templates select="../darma:Datum[@fieldName='biographies.Cite']/xhtml:html"/>
                          </cite>
                        </xsl:when>
                        <xsl:when test="ancestor::darma:Object/@collectionID eq 'c359'">
                          <html xmlns="http://www.w3.org/1999/xhtml"
                            xmlns:xhtml="http://www.w3.org/1999/xhtml"
                            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                            <head>
                              <title>Citation</title>
                            </head>
                            <body>
                              <div class="pfe-bio-bib">David A. Rawson, <i>Index of Virginia Printing</i> (2015)</div>
                            </body>
                          </html>
                        </xsl:when>
                        <xsl:otherwise>MISSING CITATION</xsl:otherwise>
                      </xsl:choose>
                      
                      <xsl:if test="../darma:Datum[matches(@fieldName, 'biographies.Rotunda')]">
                      <source>
                        <rotundaVolume>
                          <xsl:value-of select="../darma:Datum[@fieldName='biographies.RotundaSourceVolume']/darma:Value"></xsl:value-of>
                        </rotundaVolume>
                        <rotundaPages>
                          <xsl:value-of select="../darma:Datum[@fieldName='biographies.RotundaSourcePages']/darma:Value"></xsl:value-of>
                        </rotundaPages>
                        <rotundaLink>
                          <xsl:value-of select="../darma:Datum[@fieldName='biographies.RotundaSourceLink']/darma:Value"></xsl:value-of>
                        </rotundaLink>
                      </source>
                      </xsl:if>
                    </bio>
                  
                  </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
            </bios>
          </person>
        </people>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
  
  <!-- HTML templates follow for processing citations. NOTE: if this transform ever needs to modify content
       other than in the citation, the following templates should probably have @mode assigned
       so they won't interfere with processing of HTML in other parts of the input. -->
  
  <xsl:template match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>

  <!-- head elements and body down to div, pass along unchanged -->
  <xsl:template match="xhtml:body|xhtml:div|xhtml:head|xhtml:html|xhtml:title">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- clean up inconsistent data in their title formats -->
  <xsl:template match="xhtml:div[@class eq 'pfe-bio-bib']/xhtml:em[1]/text()" priority="2">
    <xsl:choose>
      <xsl:when test="normalize-space(.) = ('Adams', 'John Adams')">
        <xsl:text>The Papers of John Adams</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = ('Jefferson', 'Thomas Jefferson')">
        <xsl:text>The Papers of Thomas Jefferson</xsl:text>
      </xsl:when>
      <xsl:when test="contains(., 'Letters of Benjamin Rush')">
        <xsl:text>The Letters of Benjamin Rush</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = ('George Washington', 'Washington')">
        <xsl:text>The Papers of George Washington</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <!-- clean up  inconsistent data in their title formats -->
  <xsl:template match="xhtml:body/xhtml:p/xhtml:em[not(preceding-sibling::*)]">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="normalize-space(.) = ('Adams', 'Adams Papers', 'John Adams', 'Papers of John Adams')">
          <xsl:text>The Papers of John Adams</xsl:text>
        </xsl:when>
        <xsl:when test="normalize-space(.) = ('Jefferson', 'Thomas Jefferson')">
          <xsl:text>The Papers of Thomas Jefferson</xsl:text>
        </xsl:when>
        <xsl:when test="normalize-space(.) = ('Madison', 'Papers of James Madison')">
          <xsl:text>The Papers of James Madison</xsl:text>
        </xsl:when>
        <xsl:when test="normalize-space(.) = ('George Washington', 'Papers of George Washington')">
          <xsl:text>The Papers of George Washington</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <!-- add the proper div/@class to citations missing them -->
  <xsl:template match="xhtml:body[xhtml:p]">
    <xsl:copy>
      <div class="pfe-bio-bib" xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates select="xhtml:p/node()"/></div>
    </xsl:copy>
  </xsl:template>
  
  <!-- delete, never used properly in the data-->
  <xsl:template match="xhtml:br"/>
  
  <xsl:template match="xhtml:em">
    <xsl:copy><xsl:apply-templates/></xsl:copy>
  </xsl:template>
  
  <!-- elements we don't preserve because they don't convey necessary info in the DARMA data -->
  <xsl:template match="xhtml:p|xhtml:span|xhtml:strong">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- who knows what this is, delete ... -->
  <xsl:template match="xhtml:span[@class eq 'Apple-tab-span']" priority="1"/>
   
  <!-- clean up this rare error -->
  <xsl:template match="xhtml:span[@class eq 'italic']" priority="1">
    <em xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates/></em>
  </xsl:template>
  
  <!-- clean up erroneous spaces before comma -->
  <xsl:template match="text()[following-sibling::*[1][self::xhtml:span[starts-with(., ',')]]][matches(., '\s+$')]">
    <xsl:value-of select="replace(., '\s+$', '')"/> 
  </xsl:template>
  
</xsl:stylesheet>