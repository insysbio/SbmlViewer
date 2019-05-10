<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright 2016-2018 InSysBio, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
<!-- INFO
Description: Creating representation of single element with dependencies
Source files: SBML L2 V1-5, L3 V1-2
modes:
  - element
  - reactionFormula
  - dependencies/searchdependencies
  - idOrName/idOrNamePlus

Author: Evgeny Metelkin

Project-page: http://sv.insysbio.ru
-->
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:l2v1="http://www.sbml.org/sbml/level2/version1"
  xmlns:l2v2="http://www.sbml.org/sbml/level2/version2"
  xmlns:l2v3="http://www.sbml.org/sbml/level2/version3"
  xmlns:l2v4="http://www.sbml.org/sbml/level2/version4"
  xmlns:l2v5="http://www.sbml.org/sbml/level2/version5"
  xmlns:l3v1="http://www.sbml.org/sbml/level3/version1/core"
  xmlns:l3v2="http://www.sbml.org/sbml/level3/version2/core"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:exsl="http://exslt.org/common"
  xmlns:msexsl="urn:schemas-microsoft-com:xslt"

  exclude-result-prefixes="mml xhtml exsl msexsl l2v1 l2v2 l2v3 l2v4 l2v5 l3v1 l3v2">

  <!-- GLOBAL KEYS -->
  <xsl:key name="idKey" match="/*/*/*/*" use="@id"/><!-- to exclude local parameters -->
  <!--<xsl:key name="idKey" match="*" use="@id"/>-->
  <xsl:key name="variableKey" match="/*/*/*/*" use="@variable"/>

  <!-- PARAMETERS -->
  <xsl:param name="useNames">false</xsl:param> <!-- use names instead of id in equations -->
  <xsl:param name="correctMathml">false</xsl:param> <!-- use correction in MathML (for simbio) always on currently-->
  <xsl:param name="equationsOff">false</xsl:param> <!-- do not show equations -->
  <xsl:param name="input_root" select="/"/> <!-- main document reference -->
  <xsl:param name="elementId">default</xsl:param> <!-- include unitDefinitions and attribute -->
  <xsl:param name="isEdge">false</xsl:param> <!-- define browser -->
  <xsl:param name="dependent" >
    <ci><xsl:value-of select="$elementId"/></ci>
    <xsl:apply-templates select="key('idKey', $elementId)" mode="searchdependencies"/>
  </xsl:param>

  <!-- top element -->
  <xsl:template match="/">
    <div class="sv-container">
      <xsl:attribute name="class">sbml-element <!--sbml-<xsl:value-of select="key('idKey', $elementId)[1]/local-name()"/>--> sv-container sv-mode-element</xsl:attribute>
      <xsl:apply-templates select="key('idKey', $elementId)[1]"/>
    </div>
  </xsl:template>

  <!-- Attributes -->
  <xsl:template match="@*" mode="element">
    <p>
      <xsl:attribute name="class">sbml-attribute sbml-<xsl:value-of select="local-name()"/></xsl:attribute>
      <span class="sbml-attribute-name"><xsl:value-of select="local-name()"/></span>:
      <span class="sbml-attribute-value"><xsl:value-of select="."/></span>
    </p>
  </xsl:template>

  <!-- Annotation -->
  <xsl:template match="*[local-name()='annotation']" mode="element">
    <div class="sbml-element sbml-annotation sv-container">
      <p class="sv-header">Annotation</p>
      <pre class="sv-content sv-raw-xml prettyprint"><xsl:copy-of select="node()"/></pre>
    </div>
  </xsl:template>

  <!-- Notes -->
  <xsl:template match="*[local-name()='notes']" mode="element">
    <div class="sbml-element sbml-notes sv-container">
      <p class="sv-header">Notes</p>
      <div class="sv-content sv-xhtml">
        <xsl:copy-of select="node()"/>
      </div>
    </div>
  </xsl:template>
<!--
  <xsl:template match="*[local-name()='notes' and xhtml:body]" mode="element">
   <p><strong>notes:</strong></p>
   <div class="sv-note-content">
    <xsl:copy-of select="xhtml:body/node()"/>
   </div>
  </xsl:template>

  <xsl:template match="*[local-name()='notes' and xhtml:html[xhtml:body]]" mode="element">
   <p><strong>notes:</strong></p>
   <div class="sv-note-content">
    <xsl:copy-of select="xhtml:html/xhtml:body/node()"/>
   </div>
  </xsl:template>
-->
  <!-- compartment summary -->
  <xsl:template match="*[local-name()='compartment']
    | *[local-name()='parameter']
    | *[local-name()='species']">
      <h1 class="sv-header"><xsl:value-of select="local-name()"/></h1>
      <div class="sv-content sbml-mixed">
        <xsl:apply-templates select="@*" mode="element"/>
        <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
        <xsl:call-template name="dependencies"/>
    </div>
  </xsl:template>

  <!-- reaction summary -->
  <xsl:template match="*[local-name()='reaction']">
    <h1 class="sv-header">reaction</h1>
    <div class="sv-content sbml-mixed">
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
      <xsl:apply-templates select="." mode="reactionFormula"/>
      <xsl:apply-templates select="*[local-name()='listOfModifiers']" mode="reactionFormula"/>

      <xsl:call-template name="dependencies"/>
    </div>
  </xsl:template>

<!-- BEGIN OF idOrName/idOrNamePlus mode -->
  <xsl:template match="@id|@variable" mode="idOrName">
      <xsl:if test="$useNames='true'"><xsl:value-of select="./../@name"/></xsl:if>  <!-- for simbio only-->
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
    </xsl:template>

    <xsl:template match="@id|@variable" mode="idOrNamePlus">
      <xsl:if test="$useNames='true'"><xsl:value-of select="./../@name"/></xsl:if>  <!-- for simbio only-->
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
    </xsl:template>
<!-- END OF idOrName/idOrNamePlus mode -->

<!-- BEGIN OF reactionFormula mode -->
  <xsl:template match="*[local-name()='reaction']" mode="reactionFormula">
    <div class="sbml-mixed sv-container">
      <h2 class="sv-header">reactants / products:</h2>
      <div class="sv-content">
        <xsl:if test="count(*[local-name()='listOfReactants']/*[local-name()='speciesReference'])=0">&#8709;</xsl:if>
        <xsl:apply-templates select="*[local-name()='listOfReactants']" mode="reactionFormula"/>
        <xsl:if test="@reversible='false' and @fast='true'"> &#8594; </xsl:if>
        <xsl:if test="not(@reversible='false') and @fast='true'"> &#8596; </xsl:if>
        <xsl:if test="@reversible='false' and not(@fast='true')"> &#8658; </xsl:if>
        <xsl:if test="not(@reversible='false') and not(@fast='true')"> &#8660; </xsl:if>
        <xsl:if test="count(*[local-name()='listOfProducts']/*[local-name()='speciesReference'])=0">&#8709;</xsl:if>
        <xsl:apply-templates select="*[local-name()='listOfProducts']" mode="reactionFormula"/>
      </div>
    </div>
  </xsl:template>

  <!-- listOfReactants / listOfProducts-->
  <xsl:template match="*[local-name()='listOfReactants']
    | *[local-name()='listOfProducts']" mode="reactionFormula">
    <xsl:for-each select="*[local-name()='speciesReference']">
      <xsl:if test="@stoichiometry!='1'"><xsl:value-of select="@stoichiometry"/>&#215;</xsl:if>
      <xsl:apply-templates select="key('idKey',@species)/@id" mode="idOrName"/>
      <xsl:if test="position()!=last()"> + </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- listOfModifiers-->
  <xsl:template match="*[local-name()='listOfModifiers']" mode="reactionFormula">
    <div class="sbml-element sbml-listOf sbml-listOfModifiers sv-container">
      <h2 class="sv-header">modifiers:</h2>
      <div class="sv-content">
        <xsl:for-each select="*[local-name()='modifierSpeciesReference']">
          <xsl:apply-templates select="key('idKey',@species)/@id" mode="idOrName"/>
          <xsl:if test="position()!=last()">; </xsl:if>
        </xsl:for-each>
      </div>
    </div>
  </xsl:template>
<!-- END OF reactionFormula mode -->

<!-- BEGIN OF searchdependencies mode -->
  <xsl:template match="*[local-name()='reaction']" mode="searchdependencies">
    <xsl:for-each select="descendant::mml:ci">
      <ci><xsl:value-of select="normalize-space(text())"/></ci>
      <xsl:apply-templates select="key('idKey', normalize-space(text()))" mode="searchdependencies"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[local-name()='compartment' or local-name()='parameter']" mode="searchdependencies">
    <xsl:for-each select="key('variableKey', @id)/descendant::mml:ci">
      <ci>
      <xsl:value-of select="normalize-space(text())"/>
      </ci>
      <xsl:apply-templates select="key('idKey', normalize-space(text()))" mode="searchdependencies"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[local-name()='species']" mode="searchdependencies">
    <xsl:for-each select="key('variableKey', @id)/descendant::mml:ci">
      <ci>
      <xsl:value-of select="normalize-space(text())"/>
      </ci>
      <xsl:apply-templates select="key('idKey', normalize-space(text()))" mode="searchdependencies"/>
    </xsl:for-each>
	<!-- add compartment to search -->
	<xsl:if test="(@hasOnlySubstanceUnits='true' and @initialConcentration) or (not(@hasOnlySubstanceUnits='true') and @initialAmount)">
	  <ci><xsl:value-of select="@compartment"/></ci>
      <xsl:apply-templates select="key('idKey', @compartment)" mode="searchdependencies"/>
	</xsl:if>
  </xsl:template>
<!-- END OF searchdependencies mode -->

<!-- BEGIN OF dependencies mode -->
  <xsl:template name="dependencies">
    <div class="sbml-mixed sv-container">
      <h2 class="sv-header">dependencies:</h2>
      <div class="sv-content">
        <table>
          <xsl:if test="$isEdge='false'">
            <xsl:for-each select="exsl:node-set($dependent)/xhtml:ci[not(text()=preceding-sibling::xhtml:ci/text())]">
             <!--<xsl:apply-templates select="exsl:node-set($input_root)/descendant::*[@id=current()/text()]" mode="dependencies"/>-->
      	      <xsl:apply-templates select="exsl:node-set($input_root)/*/*/*/*[@id=current()/text()]" mode="dependencies"/> <!-- search id without local parameters -->
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="$isEdge='true'">
            <xsl:for-each select="msexsl:node-set($dependent)/xhtml:ci[not(text()=preceding-sibling::xhtml:ci/text())]">
             <!--<xsl:apply-templates select="exsl:node-set($input_root)/descendant::*[@id=current()/text()]" mode="dependencies"/>-->
      	      <xsl:apply-templates select="msexsl:node-set($input_root)/*/*/*/*[@id=current()/text()]" mode="dependencies"/> <!-- search id without local parameters -->
            </xsl:for-each>
          </xsl:if>
        </table>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='compartment' or local-name()='parameter']" mode="dependencies">
    <tr>
    <td><xsl:apply-templates select="@id" mode="idOrNamePlus"/></td>
    <td>=</td>
    <td>
    <xsl:if test="not(key('variableKey', @id))">
      <xsl:value-of select="@value"/>
      <xsl:value-of select="@size"/>
	  <xsl:if test="not(@value) and not(@size)">?</xsl:if>
    </xsl:if>
	<xsl:if test="key('variableKey', @id)">
      <xsl:apply-templates select="key('variableKey', @id)/mml:math"/>
	</xsl:if>
    </td>
    </tr>
  </xsl:template>

  <xsl:template match="*[local-name()='reaction']" mode="dependencies">
    <tr>
      <td><xsl:apply-templates select="@id"  mode="idOrNamePlus"/></td>
      <td>=</td>
      <td><xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/></td>
    </tr>
  </xsl:template>

  <xsl:template match="*[local-name()='species' and not(@hasOnlySubstanceUnits='true')]" mode="dependencies">
    <tr>
      <td><xsl:apply-templates select="@id"  mode="idOrNamePlus"/></td>
      <td>
        <xsl:if test="@boundaryCondition='true'">=</xsl:if>
        <xsl:if test="not(@boundaryCondition='true')">&#8592;</xsl:if>
      </td>
      <td>
      <xsl:if test="not(key('variableKey', @id))">
        <xsl:element name="math" namespace="http://www.w3.org/1998/Math/MathML">
              <xsl:if test="@initialConcentration">
                <cn><xsl:value-of select="@initialConcentration"/></cn>
              </xsl:if>
              <xsl:if test="@initialAmount">
                <apply>
                  <divide/>
                  <cn><xsl:value-of select="@initialAmount"/></cn>
                  <ci><xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/></ci>
                </apply>
              </xsl:if>
              <xsl:if test="not(@initialConcentration or @initialAmount)">
                <ci>?</ci>
              </xsl:if>
        </xsl:element>
        </xsl:if>
        <xsl:if test="key('variableKey', @id)">
          <xsl:apply-templates select="key('variableKey', @id)/mml:math"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="*[local-name()='species' and @hasOnlySubstanceUnits='true']" mode="dependencies">
    <tr>
      <td><xsl:apply-templates select="@id"  mode="idOrNamePlus"/></td>
    <td>
      <xsl:if test="@boundaryCondition='true'">=</xsl:if>
      <xsl:if test="not(@boundaryCondition='true')">&#8592;</xsl:if>
    </td>
    <td>
    <xsl:if test="not(key('variableKey', @id))">
      <xsl:element name="math" namespace="http://www.w3.org/1998/Math/MathML">
            <xsl:if test="@initialAmount">
              <cn><xsl:value-of select="@initialAmount"/></cn>
            </xsl:if>
            <xsl:if test="@initialConcentration">
              <apply>
                <times/>
                <cn><xsl:value-of select="@initialConcentration"/></cn>
                <ci><xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/></ci>
              </apply>
            </xsl:if>
            <xsl:if test="not(@initialConcentration or @initialAmount)">
              <ci>?</ci>
            </xsl:if>
      </xsl:element>
    </xsl:if>
    <xsl:if test="key('variableKey', @id)">
      <xsl:apply-templates select="key('variableKey', @id)/mml:math"/>
    </xsl:if>
    </td>
    </tr>
  </xsl:template>

  <xsl:template match="*[local-name()='functionDefinition']" mode="dependencies">
    <tr>
      <td>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply xmlns="http://www.w3.org/1998/Math/MathML">
            <ci xmlns="http://www.w3.org/1998/Math/MathML"><xsl:apply-templates select="@id" mode="idOrName"/></ci>
            <xsl:copy-of select="mml:math/mml:lambda/mml:bvar/mml:*"/>
          </apply>
        </math>
      </td>
      <td>&#8801;</td>
      <td>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <xsl:copy-of select="mml:math/mml:lambda/*[local-name()!='bvar']"/>
        </math>
      </td>
    </tr>
  </xsl:template>

<!-- END OF dependencies mode -->

<!-- BEGIN OF mml: part -->
  <!-- correct for max function -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='max'][following-sibling::mml:ci]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="max" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- exclude vertcat inside max -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='max'][following-sibling::mml:apply]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="max" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[2]/*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- correct for min function -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='min'][following-sibling::mml:ci]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="min" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- exclude vertcat inside min -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='min'][following-sibling::mml:apply]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="min" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[2]/*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- use id or names for equations and normalize space -->
  <xsl:template match="mml:ci">
    <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:if test="$useNames='true'"><xsl:value-of select="key('idKey',normalize-space(text()))/@name"/></xsl:if>  <!-- for simbio only-->
      <xsl:if test="not($useNames='true')"><xsl:value-of select="normalize-space(text())"/></xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- adaptation of e-notation for MathJax -->
  <xsl:template match="mml:cn[@type='e-notation']">
    <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:copy-of select="normalize-space(text()[1])"/><xsl:if test="normalize-space(text()[2])!='0'">e<xsl:copy-of select="normalize-space(text()[2])"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- just copy mml:math or not -->
  <xsl:template match="mml:math">
    <xsl:if test="$equationsOff='true'"><span class="sv-hidden">Equations are hidden</span></xsl:if>
    <xsl:if test="not($equationsOff='true')">
      <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!-- just copy all mml elements -->
  <xsl:template match="mml:*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
<!-- END OF mml: part -->
</xsl:stylesheet>
