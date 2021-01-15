<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright 2016-2021 InSysBio, LLC

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
Source files: SBML L2 V1-5
modes:
  - idOrName
  - math
  - const/diff-init/differential-equations

Author: Evgeny Metelkin
Project-page: http://sv.insysbio.com
-->
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:l2v1="http://www.sbml.org/sbml/level2"
  xmlns:l2v2="http://www.sbml.org/sbml/level2/version2"
  xmlns:l2v3="http://www.sbml.org/sbml/level2/version3"
  xmlns:l2v4="http://www.sbml.org/sbml/level2/version4"
  xmlns:l2v5="http://www.sbml.org/sbml/level2/version5"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="mml l2v5 l2v4 l2v3 l2v2 l2v1">

  <!-- GLOBAL KEYS -->
  <xsl:key name="idKey" match="*" use="@id"/>
  <xsl:key name="variableKey" match="*" use="@variable"/>

  <!-- PARAMETERS -->
  <xsl:param name="useNames">false</xsl:param> <!-- use names instead of id in equations -->
  <xsl:param name="correctMathml">false</xsl:param> <!-- use correction in MathML (for simbio) always on currently-->
  <xsl:param name="equationsOff">false</xsl:param> <!-- do not show equations -->

  <!-- top -->
  <xsl:template match="/">
    <xsl:apply-templates mode="math"/>
  </xsl:template>

  <!-- SBML -->
  <xsl:template match="*[local-name()='sbml']" mode="math">
    <div class="sbml-element sbml-sbml sv-container sv-mode-math">
      <h1 class="sv-header">SBML level <xsl:value-of select="@level"/> version <xsl:value-of select="@version"/></h1>
      <div class="sv-content">
        <xsl:apply-templates select="*[local-name()='model']" mode="math"/>
      </div>
    </div>
  </xsl:template>

  <!-- model -->
  <xsl:template match="*[local-name()='model']" mode="math">
    <div class="sbml-element sbml-model sv-container">
      <h2 class="sv-header">Model</h2>
      <div class="sbml-mixed sv-content">
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
          <xsl:call-template name="explicit-rules"/>
        </xsl:if>

        <xsl:if test="count(//*[local-name()='algebraicRule'])">
          <xsl:call-template name="implicit-rules"/>
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
          <xsl:call-template name="differential-equations"/>
        </xsl:if>

        <xsl:if test="count(//*[local-name()='event'])">
          <xsl:call-template name="events"/>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <!-- @attributes -->
  <xsl:template match="@*">
    <p>
      <xsl:attribute name="class">sbml-attribute sbml-<xsl:value-of select="local-name()"/> sv-container</xsl:attribute>
      <span class="sbml-attribute-name"><xsl:value-of select="local-name()"/></span>: <span class="sbml-attribute-value"><xsl:value-of select="."/></span>
    </p>
  </xsl:template>

  <!-- idOrName mode -->
  <xsl:template match="@id" mode="idOrName">
      <xsl:if test="$useNames='true' and count(./../@name)>0">[<xsl:value-of select="./../@name"/>]</xsl:if>  <!-- for simbio only-->
      <xsl:if test="$useNames='true' and count(./../@name)=0">[no name]</xsl:if>
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
  </xsl:template>

  <!-- functions -->
  <xsl:template name="functions">
    <div class="sbml-element sbml-listOf sbml-listOfFunctionDefinitions sv-container">
      <h2 class="sv-header">Functions:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='functionDefinition']"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='functionDefinition']">
    <p class="sbml-element sbml-functionDefinition sv-mml">
      <xsl:element name="math" namespace="http://www.w3.org/1998/Math/MathML">
        <apply>
          <equivalent/>
            <apply>
                <ci><xsl:apply-templates select="@id" mode="idOrName"/></ci>
                <xsl:copy-of select="mml:math/mml:lambda/mml:bvar/mml:*"/>
            </apply>
            <xsl:copy-of select="mml:math/mml:lambda/*[local-name()!='bvar']"/>
        </apply>
      </xsl:element>
    </p>
  </xsl:template>

  <!-- constants -->
  <xsl:template name="constants">
    <div class="sbml-mixed sv-container">
      <h2 class="sv-header">Constants:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='model']/*/*[local-name()='parameter' and not(key('variableKey',@id))]" mode="const"/>
        <xsl:apply-templates select="//*[local-name()='compartment' and not(key('variableKey',@id))]" mode="const"/>
        <xsl:apply-templates select="//*[local-name()='species' and @boundaryCondition='true' and not(key('variableKey',@id))]" mode="const"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='parameter']" mode="const">
    <p class="sbml-element sbml-parameter">
      <xsl:apply-templates select="@id" mode="idOrName"/>
      = <xsl:value-of select="@value"/><xsl:if test="not(@value)">?</xsl:if>
    </p>
  </xsl:template>

  <xsl:template match="*[local-name()='compartment']" mode="const">
    <p class="sbml-element sbml-compartment">
      <xsl:apply-templates select="@id" mode="idOrName"/>
      = <xsl:value-of select="@size"/><xsl:if test="not(@size)">?</xsl:if>
    </p>
  </xsl:template>

  <xsl:template match="*[local-name()='species' and @initialAmount]" mode="const">
    <p class="sbml-element sbml-species">
      <xsl:apply-templates select="@id" mode="idOrName"/> = <xsl:value-of select="@initialAmount"/><xsl:if test="@hasOnlySubstanceUnits!='true' and key('idKey',@compartment)/@spatialDimensions!='0'">/<xsl:value-of select="@compartment"/></xsl:if>
    </p>
  </xsl:template>

  <xsl:template match="*[local-name()='species' and @initialConcentration]" mode="const">
    <p class="sbml-element sbml-species">
      <xsl:apply-templates select="@id" mode="idOrName"/> = <xsl:value-of select="@initialConcentration"/><xsl:if test="@hasOnlySubstanceUnits='true' or key('idKey',@compartment)/@spatialDimensions='0'">*<xsl:value-of select="@compartment"/></xsl:if>
    </p>
  </xsl:template>

  <!-- explicit rules -->
  <xsl:template name="explicit-rules">
    <div class="sbml-mixed sv-container">
      <h2 class="sv-header">Explicit rules:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='assignmentRule']"/><!-- ???  -->
        <xsl:apply-templates select="//*[local-name()='reaction']"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='assignmentRule']">
    <p class="sbml-element sbml-assignmentRule">
      <xsl:if test="key('idKey',@variable)"><xsl:apply-templates select="key('idKey',@variable)/@id" mode="idOrName"/></xsl:if>
      <xsl:if test="not(key('idKey',@variable))"><span class="sv-id-lost"><xsl:value-of select="@variable"/></span></xsl:if>
      = <xsl:apply-templates select="mml:math"/>
    </p>
  </xsl:template>

  <xsl:template match="*[local-name()='reaction']">
    <p class="sbml-element sbml-reaction">
      <xsl:apply-templates select="@id" mode="idOrName"/>
      = <xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/>
      <xsl:if test="*[local-name()='kineticLaw']/*[local-name()='listOfParameters']/*[local-name()='parameter']">
        <div class="sbml-element sbml-listOf sbml-listOfParameters sv-container">
          <p>where</p>
          <xsl:apply-templates select="*[local-name()='kineticLaw']/*[local-name()='listOfParameters']/*[local-name()='parameter']" mode="const"/>
        </div>
      </xsl:if>
    </p>
  </xsl:template>

  <!-- implicit rules -->
  <xsl:template name="implicit-rules">
    <div class="sbml-mixed sv-container">
      <h2 class="sv-header">Implicit rules:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='algebraicRule']"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='algebraicRule']">
    <p class="sbml-element sbml-algebraicRule sv-container">
      0 = <xsl:apply-templates select="mml:math"/>
    </p>
  </xsl:template>

  <!-- diff-init -->
  <xsl:template name="init">
    <div class="sbml-mixed sv-container">
      <h2 class="sv-header">Initiate at start:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='species' and not(@boundaryCondition='true')]" mode="diff-init"/>
        <xsl:apply-templates select="//*[local-name()='initialAssignment']" mode="diff-init"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='initialAssignment']" mode="diff-init">
    <p class="sbml-element sbml-initialAssignment sv-container">
      <xsl:if test="key('idKey',@symbol)"><xsl:apply-templates select="key('idKey',@symbol)/@id" mode="idOrName"/></xsl:if>
      <xsl:if test="not(key('idKey',@symbol))"><span class="sv-id-lost"><xsl:value-of select="@symbol"/></span></xsl:if>
      &#8592;
      <xsl:apply-templates select="mml:math"/>
    </p>
  </xsl:template>

  <xsl:template match="*[local-name()='species' and not(@boundaryCondition='true') and not(@hasOnlySubstanceUnits='true' or key('idKey',@compartment)/@spatialDimensions='0')]" mode="diff-init">
    <p class="sbml-element sbml-species sv-container">
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

    <xsl:template match="*[local-name()='species' and not(@boundaryCondition='true') and ( @hasOnlySubstanceUnits='true' or key('idKey',@compartment)/@spatialDimensions='0')]" mode="diff-init">
      <p class="sbml-element sbml-species sv-container">
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

  <!-- differential-equations -->
  <xsl:template name="differential-equations">
    <div class="sbml-mixed sv-container">
      <h2 class="sv-header">Differential equations:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='species' and not(@boundaryCondition='true')]" mode="differential-equations"/>
        <xsl:apply-templates select="//*[local-name()='rateRule']" mode="differential-equations"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='species' and not(@boundaryCondition='true')]" mode="differential-equations">
    <p class="sbml-element sbml-species sv-container">
      (<xsl:if test="not(@hasOnlySubstanceUnits='true' or key('idKey',@compartment)/@spatialDimensions='0')"><xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/> &#8901; </xsl:if>
        <xsl:apply-templates select="@id" mode="idOrName"/>)' =
      <xsl:element name="math" namespace="http://www.w3.org/1998/Math/MathML">
        <apply>
          <plus/>
          <xsl:apply-templates select="//*[local-name()='reaction']/*/*[local-name()='speciesReference' and @species=current()/@id]" mode="differential-equations"/>
          <xsl:if test="count(//*[local-name()='reaction']/*/*[local-name()='speciesReference' and @species=current()/@id])=0"><cn>0</cn></xsl:if>
        </apply>
      </xsl:element>
    </p>
  </xsl:template>

    <xsl:template match="*[local-name()='listOfProducts']/*[local-name()='speciesReference' and not(@stoichiometry!='1')]" mode="differential-equations">
        <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML">
          <xsl:apply-templates select="../../@id" mode="idOrName"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='listOfReactants']/*[local-name()='speciesReference' and not(@stoichiometry!='1')]" mode="differential-equations">
      <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
        <minus/>
        <ci><xsl:apply-templates select="../../@id" mode="idOrName"/></ci>
      </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='listOfProducts']/*[local-name()='speciesReference' and @stoichiometry!='1']" mode="differential-equations">
      <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
        <times/>
        <cn><xsl:value-of select="@stoichiometry"/></cn>
        <ci><xsl:apply-templates select="../../@id" mode="idOrName"/></ci>
      </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='listOfReactants']/*[local-name()='speciesReference' and @stoichiometry!='1']" mode="differential-equations">
      <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
        <minus/>
        <apply>
          <times/>
          <cn><xsl:value-of select="@stoichiometry"/></cn>
          <ci> <xsl:apply-templates select="../../@id" mode="idOrName"/></ci>
        </apply>
      </xsl:element>
    </xsl:template>

  <xsl:template match="*[local-name()='rateRule']" mode="differential-equations">
    <p class="sbml-element sbml-rateRule sv-container">
      (<xsl:value-of select="@variable"/>)' =
      <xsl:element name="math" xmlns="http://www.w3.org/1998/Math/MathML">
          <xsl:apply-templates select="mml:math/mml:*"/>
      </xsl:element>
    </p>
  </xsl:template>

  <!-- events -->
  <xsl:template name="events">
    <div class="sbml-element sbml-listOf sbml-listOfEvents sv-container">
      <h2 class="sv-header">Events:</h2>
      <div class="sv-content">
        <xsl:apply-templates select="//*[local-name()='event']"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='event']">
    <div class="sbml-element sbml-event sv-content">
      When <xsl:apply-templates select="*[local-name()='trigger']/mml:math"/>
      <xsl:if test="*[local-name()='delay']"> after delay <xsl:apply-templates select="*[local-name()='delay']/mml:math"/></xsl:if>
      <xsl:apply-templates select="*[local-name()='listOfEventAssignments']/*[local-name()='eventAssignment']"/>
    </div>
  </xsl:template>

  <xsl:template match="*[local-name()='eventAssignment']">
    <p class="sbml-element sbml-eventAssignment sv-container">
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
      <xsl:if test="$useNames='true' and key('idKey',normalize-space(text()))/@name">[<xsl:value-of select="key('idKey',normalize-space(text()))/@name"/>]</xsl:if>
      <xsl:if test="$useNames='true' and not(key('idKey',normalize-space(text()))/@name)">[no name]</xsl:if>
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
