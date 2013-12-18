package Bio::KBase::fbaModelServices::Server;

use Data::Dumper;
use Moose;
use JSON;
use Bio::KBase::Log;

extends 'RPC::Any::Server::JSONRPC::PSGI';

has 'instance_dispatch' => (is => 'ro', isa => 'HashRef');
has 'user_auth' => (is => 'ro', isa => 'UserAuth');
has 'valid_methods' => (is => 'ro', isa => 'HashRef', lazy => 1,
			builder => '_build_valid_methods');
has 'loggers' => (is => 'ro', required => 1, builder => '_build_loggers');

our $CallContext;

our %return_counts = (
        'get_models' => 1,
        'get_fbas' => 1,
        'get_gapfills' => 1,
        'get_gapgens' => 1,
        'get_reactions' => 1,
        'get_compounds' => 1,
        'get_alias' => 1,
        'get_aliassets' => 1,
        'get_media' => 1,
        'get_biochemistry' => 1,
        'get_ETCDiagram' => 1,
        'import_probanno' => 1,
        'genome_object_to_workspace' => 1,
        'genome_to_workspace' => 1,
        'add_feature_translation' => 1,
        'genome_to_fbamodel' => 1,
        'import_fbamodel' => 1,
        'export_fbamodel' => 1,
        'export_object' => 1,
        'export_genome' => 1,
        'adjust_model_reaction' => 1,
        'adjust_biomass_reaction' => 1,
        'addmedia' => 1,
        'export_media' => 1,
        'runfba' => 1,
        'export_fba' => 1,
        'import_phenotypes' => 1,
        'simulate_phenotypes' => 1,
        'add_media_transporters' => 1,
        'export_phenotypeSimulationSet' => 1,
        'integrate_reconciliation_solutions' => 1,
        'queue_runfba' => 1,
        'queue_gapfill_model' => 1,
        'queue_gapgen_model' => 1,
        'queue_wildtype_phenotype_reconciliation' => 1,
        'queue_reconciliation_sensitivity_analysis' => 1,
        'queue_combine_wildtype_phenotype_reconciliation' => 1,
        'jobs_done' => 1,
        'run_job' => 1,
        'set_cofactors' => 1,
        'find_reaction_synonyms' => 1,
        'role_to_reactions' => 1,
        'reaction_sensitivity_analysis' => 1,
        'filter_iterative_solutions' => 1,
        'delete_noncontributing_reactions' => 1,
        'fasta_to_ProteinSet' => 1,
        'ProteinSet_to_Genome' => 1,
        'fasta_to_TranscriptSet' => 1,
        'TranscriptSet_to_Genome' => 1,
        'fasta_to_ContigSet' => 1,
        'ContigSet_to_Genome' => 1,
        'annotate_workspace_Genome' => 1,
        'probanno_to_genome' => 1,
        'get_mapping' => 1,
        'adjust_mapping_role' => 1,
        'adjust_mapping_complex' => 1,
        'adjust_mapping_subsystem' => 1,
        'get_template_model' => 1,
        'import_template_fbamodel' => 1,
        'adjust_template_reaction' => 1,
        'adjust_template_biomass' => 1,
        'add_stimuli' => 1,
        'import_regulatory_model' => 1,
        'compare_models' => 1,
        'compare_genomes' => 1,
        'import_metagenome_annotation' => 1,
        'models_to_community_model' => 1,
        'metagenome_to_fbamodels' => 1,
        'version' => 1,
);



sub _build_valid_methods
{
    my($self) = @_;
    my $methods = {
        'get_models' => 1,
        'get_fbas' => 1,
        'get_gapfills' => 1,
        'get_gapgens' => 1,
        'get_reactions' => 1,
        'get_compounds' => 1,
        'get_alias' => 1,
        'get_aliassets' => 1,
        'get_media' => 1,
        'get_biochemistry' => 1,
        'get_ETCDiagram' => 1,
        'import_probanno' => 1,
        'genome_object_to_workspace' => 1,
        'genome_to_workspace' => 1,
        'add_feature_translation' => 1,
        'genome_to_fbamodel' => 1,
        'import_fbamodel' => 1,
        'export_fbamodel' => 1,
        'export_object' => 1,
        'export_genome' => 1,
        'adjust_model_reaction' => 1,
        'adjust_biomass_reaction' => 1,
        'addmedia' => 1,
        'export_media' => 1,
        'runfba' => 1,
        'export_fba' => 1,
        'import_phenotypes' => 1,
        'simulate_phenotypes' => 1,
        'add_media_transporters' => 1,
        'export_phenotypeSimulationSet' => 1,
        'integrate_reconciliation_solutions' => 1,
        'queue_runfba' => 1,
        'queue_gapfill_model' => 1,
        'queue_gapgen_model' => 1,
        'queue_wildtype_phenotype_reconciliation' => 1,
        'queue_reconciliation_sensitivity_analysis' => 1,
        'queue_combine_wildtype_phenotype_reconciliation' => 1,
        'jobs_done' => 1,
        'run_job' => 1,
        'set_cofactors' => 1,
        'find_reaction_synonyms' => 1,
        'role_to_reactions' => 1,
        'reaction_sensitivity_analysis' => 1,
        'filter_iterative_solutions' => 1,
        'delete_noncontributing_reactions' => 1,
        'fasta_to_ProteinSet' => 1,
        'ProteinSet_to_Genome' => 1,
        'fasta_to_TranscriptSet' => 1,
        'TranscriptSet_to_Genome' => 1,
        'fasta_to_ContigSet' => 1,
        'ContigSet_to_Genome' => 1,
        'annotate_workspace_Genome' => 1,
        'probanno_to_genome' => 1,
        'get_mapping' => 1,
        'adjust_mapping_role' => 1,
        'adjust_mapping_complex' => 1,
        'adjust_mapping_subsystem' => 1,
        'get_template_model' => 1,
        'import_template_fbamodel' => 1,
        'adjust_template_reaction' => 1,
        'adjust_template_biomass' => 1,
        'add_stimuli' => 1,
        'import_regulatory_model' => 1,
        'compare_models' => 1,
        'compare_genomes' => 1,
        'import_metagenome_annotation' => 1,
        'models_to_community_model' => 1,
        'metagenome_to_fbamodels' => 1,
        'version' => 1,
    };
    return $methods;
}

my $DEPLOY = 'KB_DEPLOYMENT_CONFIG';
my $SERVICE = 'KB_SERVICE_NAME';

sub get_config_file
{
    my ($self) = @_;
    if(!defined $ENV{$DEPLOY}) {
        return undef;
    }
    return $ENV{$DEPLOY};
}

sub get_service_name
{
    my ($self) = @_;
    if(!defined $ENV{$SERVICE}) {
        return undef;
    }
    return $ENV{$SERVICE};
}

sub logcallback
{
    my ($self) = @_;
    $self->loggers()->{serverlog}->set_log_file(
        $self->{loggers}->{userlog}->get_log_file());
}

sub log
{
    my ($self, $level, $context, $message) = @_;
    my $user = defined($context->user_id()) ? $context->user_id(): undef; 
    $self->loggers()->{serverlog}->log_message($level, $message, $user, 
        $context->module(), $context->method(), $context->call_id(),
        $context->client_ip());
}

sub _build_loggers
{
    my ($self) = @_;
    my $submod = $self->get_service_name() || 'fbaModelServices';
    my $loggers = {};
    my $callback = sub {$self->logcallback();};
    $loggers->{userlog} = Bio::KBase::Log->new(
            $submod, {}, {ip_address => 1, authuser => 1, module => 1,
            method => 1, call_id => 1, changecallback => $callback,
            config => $self->get_config_file()});
    $loggers->{serverlog} = Bio::KBase::Log->new(
            $submod, {}, {ip_address => 1, authuser => 1, module => 1,
            method => 1, call_id => 1,
            logfile => $loggers->{userlog}->get_log_file()});
    $loggers->{serverlog}->set_log_level(6);
    return $loggers;
}

#override of RPC::Any::Server
sub handle_error {
    my ($self, $error) = @_;
    
    unless (ref($error) eq 'HASH' ||
           (blessed $error and $error->isa('RPC::Any::Exception'))) {
        $error = RPC::Any::Exception::PerlError->new(message => $error);
    }
    my $output;
    eval {
        my $encoded_error = $self->encode_output_from_exception($error);
        $output = $self->produce_output($encoded_error);
    };
    
    return $output if $output;
    
    die "$error\n\nAlso, an error was encountered while trying to send"
        . " this error: $@\n";
}

#override of RPC::Any::JSONRPC
sub encode_output_from_exception {
    my ($self, $exception) = @_;
    my %error_params;
    if (ref($exception) eq 'HASH') {
        %error_params = %{$exception};
        if(defined($error_params{context})) {
            my @errlines;
            $errlines[0] = $error_params{message};
            push @errlines, split("\n", $error_params{data});
            $self->log($Bio::KBase::Log::ERR, $error_params{context}, \@errlines);
            delete $error_params{context};
        }
    } else {
        %error_params = (
            message => $exception->message,
            code    => $exception->code,
        );
    }
    my $json_error;
    if ($self->_last_call) {
        $json_error = $self->_last_call->return_error(%error_params);
    }
    # Default to default_version. This happens when we throw an exception
    # before inbound parsing is complete.
    else {
        $json_error = $self->_default_error(%error_params);
    }
    return $self->encode_output_from_object($json_error);
}

sub call_method {
    my ($self, $data, $method_info) = @_;

    my ($module, $method, $modname) = @$method_info{qw(module method modname)};
    
    my $ctx = Bio::KBase::fbaModelServices::ServerContext->new($self->{loggers}->{userlog},
                           client_ip => $self->_plack_req->address);
    $ctx->module($modname);
    $ctx->method($method);
    $ctx->call_id($self->{_last_call}->{id});
    
    my $args = $data->{arguments};

    # Service fbaModelServices does not require authentication.
    my $new_isa = $self->get_package_isa($module);
    no strict 'refs';
    local @{"${module}::ISA"} = @$new_isa;
    local $CallContext = $ctx;
    my @result;
    {
        my $err;
        eval {
            $self->log($Bio::KBase::Log::INFO, $ctx, "start method");
            @result = $module->$method(@{ $data->{arguments} });
            $self->log($Bio::KBase::Log::INFO, $ctx, "end method");
        };
        if ($@)
        {
            my $err = $@;
            my $nicerr;
            if(ref($err) eq "Bio::KBase::Exceptions::KBaseException") {
                $nicerr = {code => -32603, # perl error from RPC::Any::Exception
                           message => $err->error,
                           data => $err->trace->as_string,
                           context => $ctx
                           };
            } else {
                my $str = "$err";
                $str =~ s/Bio::KBase::CDMI::Service::call_method.*//s; # is this still necessary? not sure
                my $msg = $str;
                $msg =~ s/ at [^\s]+.pm line \d+.\n$//;
                $nicerr =  {code => -32603, # perl error from RPC::Any::Exception
                            message => $msg,
                            data => $str,
                            context => $ctx
                            };
            }
            die $nicerr;
        }
    }
    my $result;
    if ($return_counts{$method} == 1)
    {
        $result = [[$result[0]]];
    }
    else
    {
        $result = \@result;
    }
    return $result;
}


sub get_method
{
    my ($self, $data) = @_;
    
    my $full_name = $data->{method};
    
    $full_name =~ /^(\S+)\.([^\.]+)$/;
    my ($package, $method) = ($1, $2);
    
    if (!$package || !$method) {
	$self->exception('NoSuchMethod',
			 "'$full_name' is not a valid method. It must"
			 . " contain a package name, followed by a period,"
			 . " followed by a method name.");
    }

    if (!$self->valid_methods->{$method})
    {
	$self->exception('NoSuchMethod',
			 "'$method' is not a valid method in service fbaModelServices.");
    }
	
    my $inst = $self->instance_dispatch->{$package};
    my $module;
    if ($inst)
    {
	$module = $inst;
    }
    else
    {
	$module = $self->get_module($package);
	if (!$module) {
	    $self->exception('NoSuchMethod',
			     "There is no method package named '$package'.");
	}
	
	Class::MOP::load_class($module);
    }
    
    if (!$module->can($method)) {
	$self->exception('NoSuchMethod',
			 "There is no method named '$method' in the"
			 . " '$package' package.");
    }
    
    return { module => $module, method => $method, modname => $package };
}

package Bio::KBase::fbaModelServices::ServerContext;

use strict;

=head1 NAME

Bio::KBase::fbaModelServices::ServerContext

head1 DESCRIPTION

A KB RPC context contains information about the invoker of this
service. If it is an authenticated service the authenticated user
record is available via $context->user. The client IP address
is available via $context->client_ip.

=cut

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw(user_id client_ip authenticated token
                             module method call_id));

sub new
{
    my($class, $logger, %opts) = @_;
    
    my $self = {
        %opts,
    };
    $self->{_logger} = $logger;
    $self->{_debug_levels} = {7 => 1, 8 => 1, 9 => 1,
                              'DEBUG' => 1, 'DEBUG2' => 1, 'DEBUG3' => 1};
    return bless $self, $class;
}

sub _get_user
{
    my ($self) = @_;
    return defined($self->user_id()) ? $self->user_id(): undef; 
}

sub _log
{
    my ($self, $level, $message) = @_;
    $self->{_logger}->log_message($level, $message, $self->_get_user(),
        $self->module(), $self->method(), $self->call_id(),
        $self->client_ip());
}

sub log_err
{
    my ($self, $message) = @_;
    $self->_log($Bio::KBase::Log::ERR, $message);
}

sub log_info
{
    my ($self, $message) = @_;
    $self->_log($Bio::KBase::Log::INFO, $message);
}

sub log_debug
{
    my ($self, $message, $level) = @_;
    if(!defined($level)) {
        $level = 1;
    }
    if($self->{_debug_levels}->{$level}) {
    } else {
        if ($level =~ /\D/ || $level < 1 || $level > 3) {
            die "Invalid log level: $level";
        }
        $level += 6;
    }
    $self->_log($level, $message);
}

sub set_log_level
{
    my ($self, $level) = @_;
    $self->{_logger}->set_log_level($level);
}

sub get_log_level
{
    my ($self) = @_;
    return $self->{_logger}->get_log_level();
}

sub clear_log_level
{
    my ($self) = @_;
    $self->{_logger}->clear_user_log_level();
}

1;
