# --
# Kernel/Output/HTML/OutputFilter/AdditionalToolbarSearchFields.pm
# Copyright (C) 2015 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilter::AdditionalToolbarSearchFields;

use strict;
use warnings;

use List::Util qw(first);

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::Language
    Kernel::System::Log
    Kernel::Output::HTML::Layout
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;
    return 1 if !first{ $Templatename eq $_ }keys %{ $Param{Templates} };
    return 1 if ${ $Param{Data} } !~ m{<a [^>]+ id="LogoutButton"};

    my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');
    my $LanguageObject = $Kernel::OM->Get('Kernel::Language');
    my $LogObject      = $Kernel::OM->Get('Kernel::System::Log');
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $TitleText    = $LanguageObject->Translate( "Customer number" );
    my $ShowCustomer = $ConfigObject->Get('AdditionalToolbarSearchFields::ShowCustomerNumberField');

    if ( $ShowCustomer ) {
        my $Input = qq~
            <input type="submit" style="position: absolute; height: 0px; width: 0px; border: none; padding: 0px" tabindex="-1" name="submit" value="submit" hidefocus="true" />
            <input id="FulltextCustomerNr" type="text" name="CustomerID" value="" class="W50pc" title="$TitleText" placeholder="$TitleText"/>
        ~;

        ${ $Param{Data} } =~ s{
            <form .*? name="SearchFulltext"> .*?
            \K
            </form>
        }{$Input </form> }xsm;
    }

    my $ShowState = $ConfigObject->Get('AdditionalToolbarSearchFields::ShowSearchWithState');
    if ( $ShowState ) {
        my $Baselink       = $LayoutObject->{Baselink};
        my $Search         = $LanguageObject->Translate('Search');
        my $Label          = $LanguageObject->Translate('Fulltext Search');
        my $LabelTextinput = $LanguageObject->Translate('Fulltext search');

        my $Form = qq~
            <li class="Extended SearchFulltext" style="width: 400px !important">
                <form action="$Baselink" method="post" name="SearchFulltextStateSearch">
                    <input type="submit" style="position: absolute; height: 0px; width: 0px; border: none; padding: 0px" tabindex="-1" name="submit" value="submit" hidefocus="true" />
                    <input type="hidden" name="Action" value="AgentTicketSearch"/>
                    <input type="hidden" name="Subaction" value="Search"/>
                    <input type="hidden" name="SearchTemplate" value="$Search"/>
                    <input type="hidden" name="CheckTicketNumberAndRedirect" value="1"/>

                    <select style="display:none;" name="StateIDs" multiple="multiple" id="StateIDs" size="5">
                          <option selected="selected" value="1">new</option>
                          <option selected="selected" value="4">open</option>
                          <option selected="selected" value="6">pending reminder</option>
                          <option selected="selected" value="7">pending auto close+</option>
                          <option selected="selected" value="8">pending auto close-</option>
                    </select>

                    <input type="text" name="Fulltext" id="FulltextStateSearch" value="" title="$Label" placeholder="$LabelTextinput" />
                    <input  id="CustomerIDStateSearch" type="text" name="CustomerID" size="" value="" class="W50pc" placeholder="$TitleText" title="$TitleText"/>
                </form>
            </li>
        ~;

        ${ $Param{Data} } =~ s{
            <li \s+ class="Extended \s+ SearchFulltext .*?
            \K
            </ul>
        }{$Form </ul> }xsm;
    }
    
    return ${ $Param{Data} };
}

1;
