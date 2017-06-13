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

Author: Evgeny Metelkin
Copyright: Institute for Systems Biology, Moscow
Last modification: 2017-06-03

Project-page: http://sv.insysbio.ru
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
  exclude-result-prefixes="l1v1 l1v2 l1v3 l1v4 l1v5">
  
  <!-- GLOBAL KEYS -->
  <xsl:key name="idKey" match="*" use="@id"/>
  <xsl:key name="variableKey" match="*" use="@variable"/>
  
  <!-- PARAMETERS -->
  <xsl:param name="useNames">false</xsl:param> <!-- use names instead of id in equations -->
  <xsl:param name="correctMathml">false</xsl:param> <!-- use correction in MathML (for simbio) always on currently-->

  <!-- top -->
  <xsl:template match="/">
    <div class="w3-container">
      <xsl:apply-templates mode="math"/>
    </div>
  </xsl:template>
  
<!-- BEGIN OF reactionFormula mode -->
  <!-- SBML -->
  <xsl:template match="*[local-name()='sbml']" mode="math">
      <h1 class="w3-tooltip">Equations crated by SBML level <xsl:value-of select="@level"/> version <xsl:value-of select="@version"/></h1>
      <xsl:apply-templates select="*[local-name()='model']" mode="math"/>
  </xsl:template>
  
  <!-- model -->
  <xsl:template match="*[local-name()='model']" mode="math">
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
  </xsl:template>
  
  <xsl:template match="@*">
    <p><strong><xsl:value-of select="local-name()"/></strong>: <xsl:value-of select="."/></p>
  </xsl:template>
  
  <!-- idOrName mode -->
  <xsl:template match="@id" mode="idOrName">
      <xsl:if test="$useNames='true' and count(./../@name)>0">'<xsl:value-of select="./../@name"/>'</xsl:if>  <!-- for simbio only-->
      <xsl:if test="$useNames='true' and count(./../@name)=0">'?'</xsl:if>
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
  </xsl:template>
  
  <!-- functions -->
  <xsl:template name="functions">
    <h2>Functions:</h2>
    <p>
      <xsl:apply-templates select="//*[local-name()='functionDefinition']"/>
    </p>
  </xsl:template>
  
  <xsl:template match="*[local-name()='functionDefinition']">
      <mml:math>
        <mml:apply>
          <mml:equivalent/>
            <mml:apply>
                <mml:ci><xsl:apply-templates select="@id" mode="idOrName"/></mml:ci>
                <xsl:copy-of select="mml:math/mml:lambda/mml:bvar/mml:*"/>
            </mml:apply>
            <xsl:copy-of select="mml:math/mml:lambda/*[local-name()!='bvar']"/>
        </mml:apply>
      </mml:math>
      <br/>
  </xsl:template>
  
  <!-- constants -->
  <xsl:template name="constants">
    <h2>Constants:</h2>
    <p>
      <xsl:apply-templates select="//*[local-name()='model']/*/*[local-name()='parameter'][not(key('variableKey',@id))]" mode="const"/>
      <xsl:apply-templates select="//*[local-name()='compartment'][not(key('variableKey',@id))]" mode="const"/>
      <xsl:apply-templates select="//*[local-name()='species' and @boundaryCondition='true'][not(key('variableKey',@id))]" mode="const"/>
    </p>
  </xsl:template>
  
  <xsl:template match="*[local-name()='parameter']" mode="const">
    <xsl:apply-templates select="@id" mode="idOrName"/> = <xsl:value-of select="@value"/><br/>
  </xsl:template>
  
  <xsl:template match="*[local-name()='compartment']" mode="const">
    <xsl:apply-templates select="@id" mode="idOrName"/> = <xsl:value-of select="@size"/><br/>
  </xsl:template>
  
  <xsl:template match="*[local-name()='species' and @initialAmount]" mode="const">
    <xsl:apply-templates select="@id" mode="idOrName"/> = <xsl:value-of select="@initialAmount"/><xsl:if test="@hasOnlySunstanceUnits!='true'">/<xsl:value-of select="@compartment"/></xsl:if><br/>
  </xsl:template>
  
  <xsl:template match="*[local-name()='species' and @initialConcentration]" mode="const">
    <xsl:apply-templates select="@id" mode="idOrName"/> = <xsl:value-of select="@initialConcentration"/><xsl:if test="@hasOnlySunstanceUnits='true'">*<xsl:value-of select="@compartment"/></xsl:if><br/>
  </xsl:template>
  
  <!-- explicit rules -->
  <xsl:template name="exp-rules">
    <h2>Explicit rules:</h2>
    <p>
      <xsl:apply-templates select="//*[local-name()='assignmentRule']"/><!-- ???  -->
      <!--
      <xsl:apply-templates select="//*[local-name()='model']/*/*[local-name()='parameter'][key('variableKey',@id)]" mode="explicit"/>
      <xsl:apply-templates select="//*[local-name()='compartment'][key('variableKey',@id)]" mode="explicit"/>
      <xsl:apply-templates select="//*[local-name()='species' and @boundaryCondition='true'][key('variableKey',@id)]" mode="explicit"/>
      -->
      <xsl:apply-templates select="//*[local-name()='reaction']"/>
    </p>
  </xsl:template>
  
  <xsl:template match="*[local-name()='assignmentRule']">
    <xsl:if test="key('idKey',@variable)"><xsl:apply-templates select="key('idKey',@variable)/@id" mode="idOrName"/></xsl:if>
    <xsl:if test="not(key('idKey',@variable))"><span style="color:red;"><xsl:value-of select="@variable"/></span></xsl:if>
    = <xsl:apply-templates select="mml:math"/><br/>
  </xsl:template>
  
  <!--<xsl:template match="*[local-name()='parameter']" mode="explicit">
    <xsl:apply-templates select="@id" mode="idOrName"/> = <xsl:apply-templates select="key('variableKey',@id)/mml:math"/><br/>
  </xsl:template>-->
  
  <xsl:template match="*[local-name()='reaction']">
    <xsl:apply-templates select="@id" mode="idOrName"/> = <xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/><br/>
  </xsl:template>
  
  <!-- implicit rules -->
  <xsl:template name="imp-rules">
    <h2>Implicit rules:</h2>
    <p>
      <xsl:apply-templates select="//*[local-name()='algebraicRule']"/>
    </p>
  </xsl:template>
  
  <xsl:template match="*[local-name()='algebraicRule']">
    0 = <xsl:apply-templates select="mml:math"/><br/>
  </xsl:template>
  
  <!-- diff-init -->
  <xsl:template name="init">
    <h2>Initiate at start:</h2>
    <p>
      <xsl:apply-templates select="//*[local-name()='species' and not(@boundaryCondition='true')]" mode="diff-init"/>
      <xsl:apply-templates select="//*[local-name()='initialAssignment']" mode="diff-init"/>
    </p>
  </xsl:template>
  
  <xsl:template match="*[local-name()='initialAssignment']" mode="diff-init">
    <xsl:if test="key('idKey',@symbol)"><xsl:apply-templates select="key('idKey',@symbol)/@id" mode="idOrName"/></xsl:if>
    <xsl:if test="not(key('idKey',@symbol))"><span style="color:red;"><xsl:value-of select="@symbol"/></span></xsl:if>
    &#8592; 
    <xsl:apply-templates select="mml:math"/>
      <br/>
  </xsl:template>

    <xsl:template match="*[local-name()='species' and not(@boundaryCondition='true') and not(@hasOnlySubstanceUnits='true')]" mode="diff-init">
      <xsl:apply-templates select="@id" mode="idOrName"/> &#8592; 
      <mml:math>
            <xsl:if test="@initialConcentration">
              <mml:cn><xsl:value-of select="@initialConcentration"/></mml:cn>
            </xsl:if>
            <xsl:if test="@initialAmount">
              <mml:apply>
                <mml:divide/>
                <mml:cn><xsl:value-of select="@initialAmount"/></mml:cn>
                <mml:ci><xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/></mml:ci>
              </mml:apply>
            </xsl:if>
            <xsl:if test="not(@initialConcentration or @initialAmount)">
              <mml:ci>?</mml:ci>
            </xsl:if>
      </mml:math>
      <br/>
    </xsl:template>
    
    <xsl:template match="*[local-name()='species' and not(@boundaryCondition='true') and @hasOnlySubstanceUnits='true']" mode="diff-init">
      <xsl:apply-templates select="@id" mode="idOrName"/> &#8592;
      <mml:math>
            <xsl:if test="@initialAmount">
              <mml:cn><xsl:value-of select="@initialAmount"/></mml:cn>
            </xsl:if>
            <xsl:if test="@initialConcentration">
              <mml:apply>
                <mml:times/>
                <mml:cn><xsl:value-of select="@initialConcentration"/></mml:cn>
                <mml:ci><xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/></mml:ci>
              </mml:apply>
            </xsl:if>
            <xsl:if test="not(@initialConcentration or @initialAmount)">
              <mml:ci>?</mml:ci>
            </xsl:if>
      </mml:math>
      <br/>
    </xsl:template>
  
  <!-- diff-eq -->
  <xsl:template name="diff-eq">
    <h2>Differential equations:</h2>
    <p>
      <xsl:apply-templates select="//*[local-name()='species' and not(@boundaryCondition='true')]" mode="diff-eq"/>
      <xsl:apply-templates select="//*[local-name()='rateRule']" mode="diff-eq"/>
    </p>
  </xsl:template>
  
    <xsl:template match="*[local-name()='species' and not(@boundaryCondition='true')]" mode="diff-eq">
      <mml:math>
        <mml:apply>
          <mml:eq/>
            <mml:apply>
              <mml:diff/>
              <mml:bvar>
                <mml:ci>t</mml:ci>
              </mml:bvar>
              <mml:apply>
                <mml:times/>
                <xsl:if test="not(@hasOnlySubstanceUnits='true')"><mml:ci><xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/></mml:ci></xsl:if>
                  <mml:ci><xsl:apply-templates select="@id" mode="idOrName"/></mml:ci>
              </mml:apply>
          </mml:apply>
            <mml:apply>
              <mml:plus/>
              <xsl:apply-templates select="//*[local-name()='reaction']/*/*[local-name()='speciesReference' and @species=current()/@id]" mode="diff-eq"/>
              <xsl:if test="count(//*[local-name()='reaction']/*/*[local-name()='speciesReference' and @species=current()/@id])=0"><mml:cn>0</mml:cn></xsl:if>
            </mml:apply>
        </mml:apply>
      </mml:math>
      <br/>
    </xsl:template>
  
    <xsl:template match="*[local-name()='listOfProducts']/*[local-name()='speciesReference' and not(@stoichiometry!='1')]" mode="diff-eq">
        <mml:ci><xsl:apply-templates select="../../@id" mode="idOrName"/></mml:ci>
    </xsl:template>
    
    <xsl:template match="*[local-name()='listOfReactants']/*[local-name()='speciesReference' and not(@stoichiometry!='1')]" mode="diff-eq">
      <mml:apply>
        <mml:minus/>
        <mml:ci><xsl:apply-templates select="../../@id" mode="idOrName"/></mml:ci>
      </mml:apply>
    </xsl:template>
    
    <xsl:template match="*[local-name()='listOfProducts']/*[local-name()='speciesReference' and @stoichiometry!='1']" mode="diff-eq">
      <mml:apply>
        <mml:times/>
        <mml:cn><xsl:value-of select="@stoichiometry"/></mml:cn>
        <mml:ci><xsl:apply-templates select="../../@id" mode="idOrName"/></mml:ci>
      </mml:apply>
    </xsl:template>
    
    <xsl:template match="*[local-name()='listOfReactants']/*[local-name()='speciesReference' and @stoichiometry!='1']" mode="diff-eq">
      <mml:apply>
        <mml:minus/>
        <mml:apply>
          <mml:times/>
          <mml:cn><xsl:value-of select="@stoichiometry"/></mml:cn>
          <mml:ci><xsl:apply-templates select="../../@id" mode="idOrName"/></mml:ci>
        </mml:apply>
      </mml:apply>
    </xsl:template>
    
  <xsl:template match="*[local-name()='rateRule']" mode="diff-eq">
      <mml:math>
        <mml:apply>
          <mml:eq/>
            <mml:apply>
              <mml:diff/>
              <mml:bvar>
                <mml:ci>t</mml:ci>
              </mml:bvar>
                  <mml:ci><xsl:value-of select="@variable"/></mml:ci>
            </mml:apply>
            <xsl:apply-templates select="mml:math/mml:*"/>
        </mml:apply>
      </mml:math>
      <br/>
  </xsl:template>
  
  <!-- events -->
  <xsl:template name="events">
    <h2>Events:</h2>
    <xsl:apply-templates select="//*[local-name()='event']"/>
  </xsl:template>
  
  <xsl:template match="*[local-name()='event']">
    <p>
      <strong>When </strong> <xsl:apply-templates select="*[local-name()='trigger']/mml:math"/> 
      <strong> after delay </strong> <xsl:apply-templates select="*[local-name()='delay']/mml:math"/>
      <br/><xsl:apply-templates select="*[local-name()='listOfEventAssignments']/*[local-name()='eventAssignment']"/>
    </p>
  </xsl:template>
  
  <xsl:template match="*[local-name()='eventAssignment']">
    <xsl:if test="key('idKey',@variable)"><xsl:apply-templates select="key('idKey',@variable)/@id" mode="idOrName"/></xsl:if>
    <xsl:if test="not(key('idKey',@variable))"><span style="color:red;"><xsl:value-of select="@variable"/></span></xsl:if>
    &#8592; <xsl:apply-templates select="mml:math"/><br/>
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
      <xsl:if test="$useNames='true' and not(key('idKey',normalize-space(text()))/@name)">'?'</xsl:if>
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
    <xsl:if test="$equationsOff='true'"><i style="color:red;">Equations are hidden</i></xsl:if>
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
