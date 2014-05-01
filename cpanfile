requires 'Class::Accessor::Lite::Lazy';
requires 'Data::Recursive::Encode';
requires 'Encode';
requires 'JSON', '2';
requires 'Plack::Request::WithEncoding';
requires 'Plack::Response';
requires 'Plack::Session';
requires 'Scalar::Util';
requires 'Text::Xslate', '2.0005';
requires 'parent';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
    requires 'perl', '5.008_001';
};

on test => sub {
    requires 'Test::More';
};
