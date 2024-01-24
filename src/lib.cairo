mod contracts {
    mod reflect_draft;
    mod reflect;
    mod ERC20wrapper;
    mod reflect_factory;
    mod ownable;
    mod reentrancy_guard;
}
mod interfaces {
    mod rinterface;
    mod winterface;
    mod rinterfacev2;
    mod ownable_interface;
}
#[cfg(test)]
mod tests {
    mod reflect;
    mod utils;
    mod ownable;
    mod mocks;
}
