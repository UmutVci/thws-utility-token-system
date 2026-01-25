package com.umutavci.thwscoinbackend.infrastructure.config;

import com.umutavci.thwscoinbackend.infrastructure.jpa.user.UserEntity;
import com.umutavci.thwscoinbackend.infrastructure.jpa.user.UserJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CurrentUserProvider {

    private final UserJpaRepository userRepo;

    public UserEntity getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth == null || !auth.isAuthenticated()) {
            throw new IllegalStateException("No authenticated user");
        }

        String username = auth.getName(); // JWT subject
        return userRepo.findByUsername(username)
                .orElseThrow(() -> new IllegalStateException("User not found"));
    }

    public Long getCurrentUserId() {
        return getCurrentUser().getId();
    }
}

