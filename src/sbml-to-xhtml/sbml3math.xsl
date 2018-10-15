<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright 2016-2017 Institute for Systems Biology Moscow

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
Description: Creating representation of whole sbml as systems of equations:
modes:
  - idOrName
  - math
  - const/diff-init/diff-eq

Author: Evgeny Metelkin
Copyright: InSysBio LLC, 2016-2017
Last modification: 2017-06-15

Project-page: http://sv.insysbio.ru
-->
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:l3v1="http://www.sbml.org/sbml/level3/version1/core"
  xmlns:l3v2="http://www.sbml.org/sbml/level3/version2/core"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="mml xhtml l3v2 l3v1">

  <!-- GLOBAL KEYS -->
  <xsl:key name="idKey" match="*" use="@id"/>
  <xsl:key name="variableKey" match="*" use="@variable"/>

  <!-- PARAMETERS -->
  <xsl:param name="useNames">false</xsl:param> <!-- use names instead of id in equations -->
  <xsl:param name="correctMathml">false</xsl:param> <!-- use correction in MathML (for simbio) always on currently-->
  <xsl:param name="equationsOff">false</xsl:param> <!-- do not show equations -->

  <!-- top -->
  <xsl:template match="/">
    <div id="top">
      <xsl:apply-templates mode="math"/>
    </div>
  </xsl:template>

  <!-- SBML -->
  <xsl:template match="*[local-name()='sbml']" mode="math">
    <div class="sv-sbml-container sv-mode-table">
      <h1 class="sv-sbml-header">SBML level <xsl:value-of select="@level"/> version <xsl:value-of select="@version"/></h1>
      <div class="sv-sbml-content">
        <xsl:apply-templates select="*[local-name()='model']" mode="math"/>
      </div>
    </div>
  </xsl:template>

  <!-- model -->
  <xsl:template match="*[local-name()='model']" mode="math">
    <div class="sv-container sv-model-container">
      <h2 class="sv-model-header">Model</h2>
      <div class="sv-model-content">
        <xsl:apply-templates select="@*"/>

        <xsl:if test="count(//*[local-name()='functionDefinition'])">
          <xsl:call-template name="functions"/>
        </xsl:if>
        <xsl:if test="count(
          //*[local-name()='model']/*/*[local-name()='parameter'][not(key('variableKey',@id))] |
          //*[local-name()='compartment'][not(key('variableKey',@id))] |
          //*[local-name()='species' and @boundaryCondition='true'][not(key('variableKey',@id))]
          )">
          <xsl:call-template name="constants"/>
        </xsl:if>
        <xsl:if test="count(
          //*[local-name()='assignmentRule'] |
          //*[local-name()='reaction']
          )">
          <xsl:call-template name="exp-rules"/>
        </xsl:if>
        <xsl:if test="count(//*[local-name()='algebraicRule'])">
          <xsl:call-template name="imp-rules"/>
        </xsl:if>
        <xsl:if test="count(
          //*[local-name()='species' and not(@boundaryCondition='true')] |
          //*[local-name()='initialAssignment']
          )">
          <xsl:call-template name="init"/>
        </xsl:if>
        <xsl:if test="count(
          //*[local-name()='species' and not(@boundaryCondition='true')] |
          //*[local-name()='rateRule']
          )">
          <xsl:call-template name="diff-eq"/>
        </xsl:if>
        <xsl:if test="count(//*[local-name()='event'])">
          <xsl:call-template name="events"/>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="@*">
    <p>
      <xsl:attribute name="class">sv-attribute-container sv-attribute-<xsl:value-of select="local-name()"/></xsl:attribute>
      <span class="sbml-attribute-name"><xsl:value-of select="local-name()"/></span>: <span class="sv-attribute-value"><xsl:value-of select="."/></span>
    </p>
  </xsl:template>

  <!-- idOrName mode -->
  <xsl:template match="@id" mode="idOrName">
      <xsl:if test="$useNames='true' and count(./../@name)>0">'<xsl:value-of select="./../@name"/>'</xsl:if>  <!-- for simbio only-->
      <xsl:if test="$useNames='true' and count(./../@name)=0">'=unnamed='</xsl:if>
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
  </xsl:template>

  <!-- functions -->
  <xsl:template name="functions">
    <div class="sv-container">
      <h2 class="sv-header sv-functionDefinition-header">Functions:</h2>
      <div class="sv-content sv-functionDefinition-content">
        <xsl:apply-templates select="//*[local-name()='functionDefinition']"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='functionDefinition']">
    <p>
      <math xmlns="http://www.w3.org/1998/Math/MathML">
        <apply xmlns="http://www.w3.org/1998/Math/MathML">
          <equivalent xmlns="http://www.w3.org/1998/Math/MathML"/>
            <apply xmlns="http://www.w3.org/1998/Math/MathML">
                <ci xmlns="http://www.w3.org/1998/Math/MathML"><xsl:apply-templates select="@id" mode="idOrName"/></ci>
                <xsl:copy-of select="mml:math/mml:lambda/mml:bvar/mml:*"/>
            </apply>
            <xsl:copy-of select="mml:math/mml:lambda/*[local-name()!='bvar']"/>
        </apply>
      </math>
    </p>
  </xsl:template>

  <!-- constants -->
  <xsl:template name="constants">
    <div class="sv-container">
      <h2 class="sv-header">Constants:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='model']/*/*[local-name()='parameter' and not(key('variableKey',@id))]" mode="const"/>
        <xsl:apply-templates select="//*[local-name()='compartment' and not(key('variableKey',@id))]" mode="const"/>
        <xsl:apply-templates select="//*[local-name()='species' and @boundaryCondition='true' and not(key('variableKey',@id))]" mode="const"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='parameter']" mode="const">
    <p>
      <xsl:apply-templates select="@id" mode="idOrName"/>
      = <xsl:value-of select="@value"/><xsl:if test="not(@value)">?</xsl:if>
    </p>
  </xsl:template>

  <xsl:template match="*[local-name()='compartment']" mode="const">
    <p>
      <xsl:apply-templates select="@id" mode="idOrName"/>
      = <xsl:value-of select="@size"/><xsl:if test="not(@size)">?</xsl:if>
    </p>
  </xsl:template>

  <xsl:template match="*[local-name()='species' and @initialAmount]" mode="const">
    <p>
      <xsl:apply-templates select="@id" mode="idOrName"/> = <xsl:value-of select="@initialAmount"/><xsl:if test="@hasOnlySunstanceUnits!='true'">/<xsl:value-of select="@compartment"/></xsl:if>
    </p>
  </xsl:template>

  <xsl:template match="*[local-name()='species' and @initialConcentration]" mode="const">
    <p>
      <xsl:apply-templates select="@id" mode="idOrName"/> = <xsl:value-of select="@initialConcentration"/><xsl:if test="@hasOnlySunstanceUnits='true'">*<xsl:value-of select="@compartment"/></xsl:if>
    </p>
  </xsl:template>

  <!-- explicit rules -->
  <xsl:template name="exp-rules">
    <div class="sv-container">
      <h2 class="sv-header">Explicit rules:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='assignmentRule']"/><!-- ???  -->
        <xsl:apply-templates select="//*[local-name()='reaction']"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='assignmentRule']">
    <p>
      <xsl:if test="key('idKey',@variable)"><xsl:apply-templates select="key('idKey',@variable)/@id" mode="idOrName"/></xsl:if>
      <xsl:if test="not(key('idKey',@variable))"><span class="sv-id-lost"><xsl:value-of select="@variable"/></span></xsl:if>
      = <xsl:apply-templates select="mml:math"/>
    </p>
  </xsl:template>

  <xsl:template match="*[local-name()='reaction']">
    <p>
      <xsl:apply-templates select="@id" mode="idOrName"/>
      = <xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/>
      <xsl:if test="*[local-name()='kineticLaw']/*[local-name()='listOfParameters']/*[local-name()='parameter']">
        <div class="sv-localParameters-container">
          <p>where</p>
          <xsl:apply-templates select="*[local-name()='kineticLaw']/*[local-name()='listOfParameters']/*[local-name()='parameter']" mode="const"/>
        </div>
      </xsl:if>
    </p>
  </xsl:template>

  <!-- implicit rules -->
  <xsl:template name="imp-rules">
    <div class="sv-container">
      <h2 class="sv-header">Implicit rules:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='algebraicRule']"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='algebraicRule']">
    <p>
      0 = <xsl:apply-templates select="mml:math"/>
    </p>
  </xsl:template>

  <!-- diff-init -->
  <xsl:template name="init">
    <div class="sv-container">
      <h2 class="sv-header">Initiate at start:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='species' and not(@boundaryCondition='true')]" mode="diff-init"/>
        <xsl:apply-templates select="//*[local-name()='initialAssignment']" mode="diff-init"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='initialAssignment']" mode="diff-init">
    <p>
      <xsl:if test="key('idKey',@symbol)"><xsl:apply-templates select="key('idKey',@symbol)/@id" mode="idOrName"/></xsl:if>
      <xsl:if test="not(key('idKey',@symbol))"><span class="sv-id-lost"><xsl:value-of select="@symbol"/></span></xsl:if>
      &#8592;
      <xsl:apply-templates select="mml:math"/>
    </p>
  </xsl:template>

  <xsl:template match="*[local-name()='species' and not(@boundaryCondition='true') and not(@hasOnlySubstanceUnits='true')]" mode="diff-init">
    <p>
      <xsl:apply-templates select="@id" mode="idOrName"/> &#8592;
      <xsl:if test="@initialConcentration">
        <xsl:value-of select="@initialConcentration"/>
      </xsl:if>
      <xsl:if test="@initialAmount">
        <xsl:value-of select="@initialAmount"/> / <xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/>
      </xsl:if>
      <xsl:if test="not(@initialConcentration or @initialAmount)">?</xsl:if>
    </p>
  </xsl:template>

    <xsl:template match="*[local-name()='species' and not(@boundaryCondition='true') and @hasOnlySubstanceUnits='true']" mode="diff-init">
      <p>
        <xsl:apply-templates select="@id" mode="idOrName"/> &#8592;
            <xsl:if test="@initialAmount">
              <xsl:value-of select="@initialAmount"/>
            </xsl:if>
            <xsl:if test="@initialConcentration">
              <xsl:value-of select="@initialConcentration"/> &#8901; <xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/>
            </xsl:if>
            <xsl:if test="not(@initialConcentration or @initialAmount)">?</xsl:if>
      </p>
    </xsl:template>

  <!-- diff-eq -->
  <xsl:template name="diff-eq">
    <div class="sv-container">
      <h2 class="sv-header">Differential equations:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='species' and not(@boundaryCondition='true')]" mode="diff-eq"/>
        <xsl:apply-templates select="//*[local-name()='rateRule']" mode="diff-eq"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='species' and not(@boundaryCondition='true')]" mode="diff-eq">
    <p>
      (<xsl:if test="not(@hasOnlySubstanceUnits='true')"><xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/> &#8901; </xsl:if>
        <xsl:apply-templates select="@id" mode="idOrName"/>)' =
      <math xmlns="http://www.w3.org/1998/Math/MathML">
            <apply xmlns="http://www.w3.org/1998/Math/MathML">
              <plus xmlns="http://www.w3.org/1998/Math/MathML"/>
              <xsl:apply-templates select="//*[local-name()='reaction']/*/*[local-name()='speciesReference' and @species=current()/@id]" mode="diff-eq"/>
              <xsl:if test="count(//*[local-name()='reaction']/*/*[local-name()='speciesReference' and @species=current()/@id])=0"><cn xmlns="http://www.w3.org/1998/Math/MathML">0</cn></xsl:if>
            </apply>
      </math>
    </p>
  </xsl:template>

    <xsl:template match="*[local-name()='listOfProducts']/*[local-name()='speciesReference' and not(@stoichiometry!='1')]" mode="diff-eq">
        <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML">
          <xsl:apply-templates select="../../@id" mode="idOrName"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='listOfReactants']/*[local-name()='speciesReference' and not(@stoichiometry!='1')]" mode="diff-eq">
      <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
        <minus xmlns="http://www.w3.org/1998/Math/MathML"/>
        <ci xmlns="http://www.w3.org/1998/Math/MathML"><xsl:apply-templates select="../../@id" mode="idOrName"/></ci>
      </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='listOfProducts']/*[local-name()='speciesReference' and @stoichiometry!='1']" mode="diff-eq">
      <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
        <times xmlns="http://www.w3.org/1998/Math/MathML"/>
        <cn xmlns="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="@stoichiometry"/></cn>
        <ci xmlns="http://www.w3.org/1998/Math/MathML"><xsl:apply-templates select="../../@id" mode="idOrName"/></ci>
      </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='listOfReactants']/*[local-name()='speciesReference' and @stoichiometry!='1']" mode="diff-eq">
      <!--<apply xmlns="http://www.w3.org/1998/Math/MathML">-->
      <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
        <minus xmlns="http://www.w3.org/1998/Math/MathML"/>
        <apply xmlns="http://www.w3.org/1998/Math/MathML">
          <times xmlns="http://www.w3.org/1998/Math/MathML"/>
          <cn xmlns="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="@stoichiometry"/></cn>
          <ci xmlns="http://www.w3.org/1998/Math/MathML"> <xsl:apply-templates select="../../@id" mode="idOrName"/></ci>
        </apply>
      <!--</apply>-->
      </xsl:element>
    </xsl:template>

  <xsl:template match="*[local-name()='rateRule']" mode="diff-eq">
    <p>
      (<xsl:value-of select="@variable"/>)' =
      <math xmlns="http://www.w3.org/1998/Math/MathML">
          <xsl:apply-templates select="mml:math/mml:*"/>
      </math>
    </p>
  </xsl:template>

  <!-- events -->
  <xsl:template name="events">
    <div class="sv-container">
      <h2 class="sv-header">Events:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='event']"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='event']">
    <div class="sv-content">
      When <xsl:apply-templates select="*[local-name()='trigger']/mml:math"/>
      <xsl:if test="*[local-name()='delay']"> after delay <xsl:apply-templates select="*[local-name()='delay']/mml:math"/></xsl:if>
      <xsl:apply-templates select="*[local-name()='listOfEventAssignments']/*[local-name()='eventAssignment']"/>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='eventAssignment']">
    <p>
      <xsl:if test="key('idKey',@variable)"><xsl:apply-templates select="key('idKey',@variable)/@id" mode="idOrName"/></xsl:if>
      <xsl:if test="not(key('idKey',@variable))"><span class="sv-id-lost"><xsl:value-of select="@variable"/></span></xsl:if>
      &#8592; <xsl:apply-templates select="mml:math"/>
    </p>
  </xsl:template>

  <!-- BEGIN OF mml -->
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
      <xsl:if test="$useNames='true' and key('idKey',normalize-space(text()))/@name">'<xsl:value-of select="key('idKey',normalize-space(text()))/@name"/>'</xsl:if>
      <xsl:if test="$useNames='true' and not(key('idKey',normalize-space(text()))/@name)">'=unnamed='</xsl:if>
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

  <!-- adaptation of integer for MathJax -->
  <xsl:template match="mml:cn[@type='integer']">
    <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:copy-of select="normalize-space(text())"/>
    </xsl:element>
  </xsl:template>

  <!-- just copy mml or not -->
  <xsl:template match="mml:math">
    <xsl:if test="$equationsOff='true'">= Equations are hidden =</xsl:if>
    <xsl:if test="not($equationsOff='true')">
      <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mml:*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
